//
//  ContractionTrackerView.swift
//  BamiLog
//
//  Created by Leeo on 11/16/25.
//


import SwiftUI

struct ContractionTrackerView: View {
    @EnvironmentObject var contractionManager: ContractionManager
    @State private var isShowingHistory = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                // 배경 - 다크/라이트 모드 대응
                AppColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // 진통 단계 카드
                        StageCard(stage: contractionManager.currentStage)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                        // 통계 카드
                        if contractionManager.contractions.count >= 2 {
                            StatisticsCard(
                                averageInterval: contractionManager.averageInterval,
                                lastInterval: contractionManager.lastInterval
                            )
                            .padding(.horizontal, 16)
                        }

                        // 진통 기록 버튼
                        Button(action: {
                            contractionManager.recordContraction()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                Text("진통 시작")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 16)

                        // 최근 진통 목록
                        if !contractionManager.contractions.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                // 전체 과정 요약 바 (최근 진통 위쪽)
                                ContractionSummaryBar(contractions: contractionManager.contractions)
                                    .padding(.horizontal, 16)

                                HStack {
                                    Text("최근 진통")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(AppColors.textPrimary)

                                    Spacer()

                                    Button(action: {
                                        isShowingHistory = true
                                    }) {
                                        Text("전체 보기")
                                            .font(.system(size: 13))
                                            .foregroundColor(.cyan)
                                    }
                                }
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
                                    .foregroundColor(AppColors.textSecondary.opacity(0.5))

                                Text("아직 기록된 진통이 없습니다")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textSecondary)

                                Text("진통이 시작되면 위 버튼을 눌러주세요")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                            .padding(.top, 20)
                        }

                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingHistory) {
                ContractionHistoryView()
                    .environmentObject(contractionManager)
            }
            .alert("모든 진통 기록 삭제", isPresented: $showDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    contractionManager.deleteAllContractions()
                }
            } message: {
                Text("모든 진통 기록을 삭제하시겠습니까?")
            }
        }
    }
}

// 진통 단계 카드
struct StageCard: View {
    let stage: LaborStage

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: stage == .none ? "moon.stars" : "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(stage.color)

                Text(stage.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()
            }

            Text(stage.description)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(stage.color.opacity(0.3), lineWidth: 2)
        )
    }
}

// 통계 카드
struct StatisticsCard: View {
    let averageInterval: Double?
    let lastInterval: TimeInterval?

    var body: some View {
        HStack(spacing: 20) {
            // 평균 간격
            StatItem(
                icon: "chart.bar.fill",
                title: "평균 간격",
                value: averageInterval.map { formatInterval($0 * 60) } ?? "-",
                color: .cyan
            )

            Divider()
                .background(AppColors.textSecondary)

            // 최근 간격
            StatItem(
                icon: "clock.fill",
                title: "최근 간격",
                value: lastInterval.map { formatInterval($0) } ?? "-",
                color: .blue
            )
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(14)
    }

    func formatInterval(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        if minutes > 0 {
            return String(format: "%d분 %02d초", minutes, seconds)
        } else {
            return String(format: "%d초", seconds)
        }
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

// 진통 행
struct ContractionRow: View {
    let contraction: Contraction
    let previousContraction: Contraction?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                // 왼쪽: 주기와 진통을 세로로
                VStack(alignment: .leading, spacing: 8) {
                    // 1. 진통 간격
                    if let previous = previousContraction {
                        let interval = contraction.timestamp.timeIntervalSince(previous.timestamp)
                        HStack(spacing: 5) {
                            Text("휴식")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.cyan.opacity(0.8))
                            Text(formatInterval(interval))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.cyan)
                        }
                    } else {
                        HStack(spacing: 5) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                            Text("첫 진통")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.yellow)
                    }

                    // 2. 지속 시간
                    if let duration = contraction.duration {
                        HStack(spacing: 5) {
                            Text("진통")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.orange.opacity(0.8))
                            Text(formatDuration(duration))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.orange)
                        }
                    }
                }

                Spacer()

                // 오른쪽: 통증
                if let painLevel = contraction.painLevel {
                    HStack(spacing: 5) {
                        Text("통증")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.red.opacity(0.8))
                        Text("\(painLevel)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red)
                    }
                }
            }

            // 시간 (오른쪽 아래)
            HStack {
                Spacer()
                Text(formattedTime(contraction.timestamp))
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func formatInterval(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        if minutes > 0 {
            return String(format: "%d분 %02d초", minutes, seconds)
        } else {
            return String(format: "%d초", seconds)
        }
    }

    func formatDuration(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        if minutes > 0 {
            return String(format: "%d분 %02d초", minutes, seconds)
        } else {
            return String(format: "%d초", seconds)
        }
    }
}

// 전체 과정 요약 바 - 시각적 스택 차트
struct ContractionSummaryBar: View {
    let contractions: [Contraction]

    // 차트 세그먼트 데이터
    struct ChartSegment: Identifiable {
        let id = UUID()
        let type: SegmentType
        let minutes: Double
        let color: Color

        enum SegmentType {
            case duration
            case interval
        }
    }

    var chartSegments: [ChartSegment] {
        let recentContractions = Array(contractions.prefix(5).reversed()) // 시간 순서대로
        var segments: [ChartSegment] = []

        for (index, contraction) in recentContractions.enumerated() {
            // 길이 추가
            if let duration = contraction.duration {
                segments.append(ChartSegment(
                    type: .duration,
                    minutes: duration / 60,
                    color: .orange
                ))
            }

            // 간격 추가 (다음 진통과의 간격)
            if index < recentContractions.count - 1 {
                let nextContraction = recentContractions[index + 1]
                let interval = nextContraction.timestamp.timeIntervalSince(contraction.timestamp)
                segments.append(ChartSegment(
                    type: .interval,
                    minutes: interval / 60,
                    color: .cyan
                ))
            }
        }

        return segments
    }

    var totalMinutes: Double {
        chartSegments.reduce(0) { $0 + $1.minutes }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 제목과 범례
            HStack {
                Text("진통 패턴")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                // 범례
                HStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Circle()
                            .fill(.orange)
                            .frame(width: 6, height: 6)
                        Text("진통")
                            .font(.system(size: 10))
                            .foregroundColor(.orange.opacity(0.8))
                    }
                    HStack(spacing: 3) {
                        Circle()
                            .fill(.cyan)
                            .frame(width: 6, height: 6)
                        Text("휴식")
                            .font(.system(size: 10))
                            .foregroundColor(.cyan.opacity(0.8))
                    }
                }
            }

            // 스택 차트
            if !chartSegments.isEmpty && totalMinutes > 0 {
                VStack(spacing: 4) {
                    // 시간 레이블
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            ForEach(chartSegments) { segment in
                                let width = geometry.size.width * (segment.minutes / totalMinutes)

                                // 폭이 30pt 이상일 때만 숫자 표시
                                if width >= 30 {
                                    Text(String(format: "%.0f", segment.minutes))
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(segment.color)
                                        .frame(width: width)
                                } else {
                                    Text("")
                                        .frame(width: width)
                                }
                            }
                        }
                    }
                    .frame(height: 18)

                    // 차트 바
                    GeometryReader { geometry in
                        HStack(spacing: 2) {
                            ForEach(chartSegments) { segment in
                                let width = geometry.size.width * (segment.minutes / totalMinutes)

                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [segment.color, segment.color.opacity(0.7)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: max(width - 2, 0))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .frame(height: 28)

                    // 단위 표시
                    Text("(분)")
                        .font(.system(size: 9))
                        .foregroundColor(AppColors.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            } else {
                Text("진통 기록이 충분하지 않습니다")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.vertical, 8)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(AppColors.secondaryBackground)
        .cornerRadius(12)
    }
}

#Preview {
    ContractionTrackerView()
        .environmentObject(ContractionManager())
}
