//
//  ContractionTrackingPhaseView.swift
//  laborBreath
//
//  Created by Claude on 11/14/24.
//

import SwiftUI

struct ContractionTrackingPhaseView: View {
    @EnvironmentObject var contractionManager: ContractionManager
    @EnvironmentObject var appState: AppState
    @State private var isShowingHistory = false
    @State private var showDeleteAlert = false

    // 진통 타이머 관련
    @State private var isContracting = false
    @State private var contractionStartTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var painCount: Int = 0 // 아파요 버튼 누른 횟수

    // 휴식 타이머 관련
    @State private var restStartTime: Date?
    @State private var restElapsedTime: TimeInterval = 0

    // 배경 애니메이션
    @State private var pulseAnimation = false

    var body: some View {
        ZStack {
            // 배경 - 시스템 배경 사용으로 가독성 향상
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // 섹션 헤더와 설정 버튼
                        SectionHeaderWithSettings("진통 기록", settingsAction: {
                            appState.showSettings = true
                        }, resetAction: {
                            showDeleteAlert = true
                        })
                        .padding(.top, 12)

                        // 현재 상태와 타이머 통합 카드
                        ContractionStatusCard(
                            isContracting: isContracting,
                            hasContractions: !contractionManager.contractions.isEmpty,
                            elapsedTime: elapsedTime,
                            painCount: painCount,
                            restElapsedTime: restElapsedTime
                        )
                        .padding(.horizontal, 16)

                        // 통계 카드
                        if contractionManager.contractions.count >= 2 {
                            StatisticsCard(
                                averageInterval: contractionManager.averageInterval,
                                lastInterval: contractionManager.lastInterval
                            )
                            .padding(.horizontal, 16)
                        }

                    // 최근 진통 목록
                    if !contractionManager.contractions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            // 전체 과정 요약 바
                            ContractionSummaryBar(contractions: contractionManager.contractions)
                                .padding(.horizontal, 16)

                            SectionHeader("최근 진통", action: {
                                isShowingHistory = true
                            }, actionLabel: "전체 보기")
                            .padding(.horizontal, 16)

                            ForEach(Array(contractionManager.contractions.prefix(5).enumerated()), id: \.element.id) { index, contraction in
                                ContractionRow(
                                    contraction: contraction,
                                    previousContraction: index < contractionManager.contractions.count - 1 ? contractionManager.contractions[index + 1] : nil
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                    } else {
                        // 빈 상태
                        VStack(spacing: 12) {
                            Image(systemName: "heart.text.square")
                                .font(.system(size: 50))
                                .foregroundColor(AppColors.textSecondary)

                            Text("아직 기록된 진통이 없습니다")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textSecondary)

                            Text("진통이 시작되면 아래 버튼을 눌러주세요")
                                .font(AppTypography.footnote)
                                .foregroundColor(AppColors.textSecondary.opacity(0.7))
                        }
                        .padding(.top, 20)
                    }

                        Spacer(minLength: 100) // 하단 버튼 공간 확보
                    }
                }

                // 하단 고정 버튼
                VStack(spacing: 0) {
                    Divider()

                    if isContracting {
                        // 진통 중: 진통 종료 + 아파요 버튼
                        HStack(spacing: 12) {
                            // 진통 종료 버튼
                            AppButton(
                                "진통 종료",
                                icon: "stop.circle.fill",
                                color: AppColors.error
                            ) {
                                endContraction()
                            }

                            // 아파요 버튼
                            AppButton(
                                "아파요",
                                icon: "exclamationmark.triangle.fill",
                                color: AppColors.warning
                            ) {
                                painCount += 1
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                    } else {
                        // 진통 시작 버튼
                        AppButton(
                            "진통 시작",
                            icon: "plus.circle.fill",
                            color: AppColors.phase1,
                            fullWidth: true
                        ) {
                            startContraction()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                    }
                }
                .background(AppColors.cardBackground)
            }
        }
        .sheet(isPresented: $isShowingHistory) {
            ContractionHistoryView()
                .environmentObject(contractionManager)
        }
        .alert("진통 기록 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                contractionManager.deleteAllContractions()
            }
        } message: {
            Text("모든 기록을 삭제할까요?")
        }
        .onAppear {
            // 배경 애니메이션 시작
            pulseAnimation = true

            // 앱 재시작 시: 진통 기록이 있고 휴식 타이머가 없으면 휴식 타이머 시작
            if !contractionManager.contractions.isEmpty && !isContracting && restStartTime == nil {
                // 마지막 진통 시간을 기준으로 휴식 타이머 시작
                if let lastContraction = contractionManager.contractions.first {
                    restStartTime = lastContraction.timestamp

                    // 타이머 시작 - common 모드로 실행하여 스크롤 중에도 동작
                    timer = Timer(timeInterval: 0.1, repeats: true) { [self] _ in
                        if let startTime = restStartTime {
                            restElapsedTime = Date().timeIntervalSince(startTime)
                        }
                    }
                    RunLoop.main.add(timer!, forMode: .common)
                }
            }
        }
        .onDisappear {
            // 타이머 정리
            timer?.invalidate()
        }
    }

    // 진통 시작
    func startContraction() {
        isContracting = true
        appState.isContracting = true // AppState 업데이트
        contractionStartTime = Date()
        elapsedTime = 0
        painCount = 0 // 아파요 카운터 초기화

        // 휴식 타이머 정지
        restStartTime = nil
        restElapsedTime = 0

        // 타이머 시작 (0.1초마다 업데이트) - common 모드로 실행하여 스크롤 중에도 동작
        timer = Timer(timeInterval: 0.1, repeats: true) { [self] _ in
            if let startTime = contractionStartTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    // 진통 종료
    func endContraction() {
        // 진통 타이머 정지
        timer?.invalidate()

        // 진통 기록 저장 (duration과 painLevel 포함)
        contractionManager.recordContraction(duration: elapsedTime, painLevel: painCount > 0 ? painCount : nil)

        // 상태 초기화
        isContracting = false
        appState.isContracting = false // AppState 업데이트
        contractionStartTime = nil
        elapsedTime = 0
        painCount = 0

        // 휴식 타이머 시작 - common 모드로 실행하여 스크롤 중에도 동작
        restStartTime = Date()
        restElapsedTime = 0
        timer = Timer(timeInterval: 0.1, repeats: true) { [self] _ in
            if let startTime = restStartTime {
                restElapsedTime = Date().timeIntervalSince(startTime)
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    // 경과 시간 포맷팅 (분분 초초)
    func formatElapsedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d분 %02d초", minutes, seconds)
    }
}

// 현재 상태와 타이머 통합 카드
struct ContractionStatusCard: View {
    let isContracting: Bool
    let hasContractions: Bool
    let elapsedTime: TimeInterval
    let painCount: Int
    let restElapsedTime: TimeInterval

    var currentState: (title: String, description: String, color: Color, icon: String) {
        if isContracting {
            return ("진통 중", "타이머를 확인하고 진통이 끝나면 종료 버튼을 누르세요", AppColors.error, "exclamationmark.circle.fill")
        } else if hasContractions {
            return ("휴식 중", "다음 진통이 시작되면 진통 시작 버튼을 누르세요", AppColors.success, "pause.circle.fill")
        } else {
            return ("진통 대기 중", "진통이 시작되면 아래 버튼을 눌러주세요", AppColors.textSecondary, "moon.stars.fill")
        }
    }

    var body: some View {
        let state = currentState

        VStack(spacing: 12) {
            // 상태 헤더
            HStack {
                Image(systemName: state.icon)
                    .font(.system(size: 20))
                    .foregroundColor(state.color)

                Text(state.title)
                    .font(AppTypography.title3)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()
            }

            // 진통 중일 때: 진통 시간과 통증 수준 표시
            if isContracting {
                VStack(spacing: 16) {
                    // 타이머
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(AppColors.error)
                                .frame(width: 12, height: 12)
                            Text("진통 시간")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                        }

                        Text(formatElapsedTime(elapsedTime))
                            .font(.system(size: 52, weight: .bold))
                            .foregroundColor(AppColors.error)
                    }
                    .padding(20)
                    .background(AppColors.error.opacity(0.1))
                    .cornerRadius(AppRadius.lg)

                    // 아파요 카운터
                    HStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.warning)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("통증 수준")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            Text("\(painCount)회")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppColors.warning)
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(AppColors.warning.opacity(0.1))
                    .cornerRadius(AppRadius.md)
                }
            } else if hasContractions {
                // 휴식 중일 때: 휴식 시간 (진통 간격) 표시
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(AppColors.success)
                            .frame(width: 12, height: 12)
                        Text("휴식 시간 (진통 간격)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                    }

                    Text(formatElapsedTime(restElapsedTime))
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(AppColors.success)
                }
                .padding(20)
                .background(AppColors.success.opacity(0.1))
                .cornerRadius(AppRadius.lg)
            } else {
                // 진통 대기 중일 때는 설명만 표시
                Text(state.description)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .appCardStyle()
    }

    func formatElapsedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d분 %02d초", minutes, seconds)
    }
}

#Preview {
    ContractionTrackingPhaseView()
        .environmentObject(ContractionManager())
        .environmentObject(AppState())
}
