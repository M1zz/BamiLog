//
//  ContractionTrackingPhaseView.swift
//  BamiLog
//
//  Created by Leeo on 11/16/25.
//

import SwiftUI

struct ContractionTrackingPhaseView: View {
    @EnvironmentObject var contractionManager: ContractionManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userProfileManager: UserProfileManager
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

    // 타이머 수동 정지 상태 (앱 재시작 후에도 유지)
    @AppStorage("timerManuallyStopped") private var timerManuallyStopped: Bool = false

    var body: some View {
        ZStack {
            // 배경 - 시스템 배경 사용으로 가독성 향상
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // 섹션 헤더 (설정 버튼은 toolbar로 이동)
                        HStack {
                            Text("진통 기록")
                                .font(AppTypography.title3)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 4)

                        // 현재 상태와 타이머 통합 카드
                        ContractionStatusCard(
                            isContracting: isContracting,
                            hasContractions: !contractionManager.contractions.isEmpty,
                            elapsedTime: elapsedTime,
                            restElapsedTime: restElapsedTime,
                            breathingPattern: contractionManager.selectedBreathingPattern
                        )
                        .padding(.horizontal, 16)

                        // 통계 카드
                        if contractionManager.contractions.count >= 2 {
                            StatisticsCard(
                                averageInterval: contractionManager.averageInterval,
                                lastInterval: contractionManager.lastInterval,
                                userRole: userProfileManager.profile?.userRole ?? .firstTimeMother
                            )
                            .padding(.horizontal, 16)
                        }

                    // 최근 진통 목록
                    if !contractionManager.contractions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            // 전체 과정 요약 바
                            ContractionSummaryBar(contractions: contractionManager.contractions)
                                .padding(.horizontal, 16)

                            // 통증 수준 그래프
                            PainLevelChartView(contractions: contractionManager.contractions)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)

                            SectionHeader("최근 진통", action: {
                                isShowingHistory = true
                            }, actionLabel: "전체 보기")
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                            ForEach(Array(contractionManager.contractions.prefix(5).enumerated()), id: \.element.id) { index, contraction in
                                ContractionRow(
                                    contraction: contraction,
                                    previousContraction: index < contractionManager.contractions.count - 1 ? contractionManager.contractions[index + 1] : nil
                                )
                                .padding(.horizontal, 16)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        // 실제 인덱스 찾기
                                        if let actualIndex = contractionManager.contractions.firstIndex(where: { $0.id == contraction.id }) {
                                            contractionManager.deleteContraction(at: IndexSet(integer: actualIndex))
                                        }
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
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

            // 앱 재시작 시: 사용자가 수동으로 정지하지 않았고, 진통 기록이 있고, 휴식 타이머가 없으면 휴식 타이머 시작
            if !timerManuallyStopped && !contractionManager.contractions.isEmpty && !isContracting && restStartTime == nil {
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

            // NotificationCenter 옵저버 등록 (toolbar 버튼용)
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("StopContraction"),
                object: nil,
                queue: .main
            ) { [self] _ in
                stopContraction()
            }

            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("ShowDeleteAlert"),
                object: nil,
                queue: .main
            ) { [self] _ in
                showDeleteAlert = true
            }
        }
        .onDisappear {
            // 타이머 정리
            timer?.invalidate()

            // NotificationCenter 옵저버 제거
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("StopContraction"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ShowDeleteAlert"), object: nil)
        }
    }

    // 진통 시작
    func startContraction() {
        // 기존 타이머 정리 (휴식 타이머 포함)
        timer?.invalidate()
        timer = nil

        // 수동 정지 상태 해제
        timerManuallyStopped = false

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
                appState.contractionElapsedTime = elapsedTime // AppState 업데이트
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    // 진통 종료
    func endContraction() {
        // 진통 타이머 정지
        timer?.invalidate()

        // 수동 정지 상태 해제 (정상적인 진통 종료)
        timerManuallyStopped = false

        // 진통 기록 저장 (duration과 painLevel 포함)
        contractionManager.recordContraction(duration: elapsedTime, painLevel: painCount > 0 ? painCount : nil)

        // 상태 초기화
        isContracting = false
        appState.isContracting = false // AppState 업데이트
        appState.contractionElapsedTime = 0 // 경과 시간 초기화
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

    // 진통 타이머 중지 (완전 초기화)
    func stopContraction() {
        // 모든 타이머 정지
        timer?.invalidate()
        timer = nil

        // 수동 정지 상태로 설정 (앱 재시작 시 자동으로 타이머 시작 안 함)
        timerManuallyStopped = true

        // 진통 상태 완전 초기화
        isContracting = false
        appState.isContracting = false
        appState.contractionElapsedTime = 0
        contractionStartTime = nil
        elapsedTime = 0
        painCount = 0

        // 휴식 상태도 완전 초기화
        restStartTime = nil
        restElapsedTime = 0

        // 진통 대기 중 상태로 돌아감 (타이머 없음)
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
    let restElapsedTime: TimeInterval
    let breathingPattern: BreathingPattern

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

            // 진통 중일 때: 진통 시간과 호흡 가이드 표시
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
                            .font(.system(size: 52, weight: .bold).monospacedDigit())
                            .foregroundColor(AppColors.error)
                            .frame(minWidth: 200)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(AppColors.error.opacity(0.1))
                    .cornerRadius(AppRadius.lg)

                    // 호흡 가이드
                    BreathingGuideView(pattern: breathingPattern)
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
                        .font(.system(size: 52, weight: .bold).monospacedDigit())
                        .foregroundColor(AppColors.success)
                        .frame(minWidth: 200)
                }
                .frame(maxWidth: .infinity)
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

// 호흡 가이드 뷰
struct BreathingGuideView: View {
    let pattern: BreathingPattern

    @State private var breathingPhase: BreathingPhase = .inhale
    @State private var scale: CGFloat = 0.7
    @State private var timer: Timer?
    @State private var phaseTimer: Timer?

    enum BreathingPhase {
        case inhale
        case hold
        case exhale

        var text: String {
            switch self {
            case .inhale: return "숨을 들이쉬세요"
            case .hold: return "숨을 멈추세요"
            case .exhale: return "숨을 내쉬세요"
            }
        }

        var color: Color {
            switch self {
            case .inhale: return .blue
            case .hold: return .yellow
            case .exhale: return .green
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // 안내 텍스트
            Text(breathingPhase.text)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
                .animation(.easeInOut(duration: 0.3), value: breathingPhase)

            // 호흡 원형 애니메이션
            ZStack {
                // 외곽 링
                Circle()
                    .stroke(breathingPhase.color.opacity(0.3), lineWidth: 3)
                    .frame(width: 200, height: 200)

                // 내부 원 (애니메이션)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                breathingPhase.color.opacity(0.8),
                                breathingPhase.color.opacity(0.4)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: getCurrentPhaseDuration()), value: scale)
            }

            // 패턴 설명
            Text(pattern.description)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(breathingPhase.color.opacity(0.05))
        .cornerRadius(AppRadius.lg)
        .onAppear {
            startBreathing()
        }
        .onDisappear {
            stopBreathing()
        }
    }

    private func getCurrentPhaseDuration() -> Double {
        switch breathingPhase {
        case .inhale: return pattern.inhaleTime
        case .hold: return pattern.holdTime
        case .exhale: return pattern.exhaleTime
        }
    }

    private func startBreathing() {
        // 초기 상태 설정
        breathingPhase = .inhale
        scale = 0.7

        // 첫 번째 들숨 애니메이션 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scale = 1.2
        }

        // 호흡 사이클 시작
        scheduleNextPhase(after: pattern.inhaleTime)
    }

    private func scheduleNextPhase(after delay: Double) {
        phaseTimer?.invalidate()

        phaseTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            switch breathingPhase {
            case .inhale:
                if pattern.holdTime > 0 {
                    // 멈춤 단계가 있으면
                    breathingPhase = .hold
                    scale = 1.2 // 크기 유지
                    scheduleNextPhase(after: pattern.holdTime)
                } else {
                    // 멈춤 단계가 없으면 바로 날숨으로
                    breathingPhase = .exhale
                    scale = 0.7
                    scheduleNextPhase(after: pattern.exhaleTime)
                }

            case .hold:
                breathingPhase = .exhale
                scale = 0.7
                scheduleNextPhase(after: pattern.exhaleTime)

            case .exhale:
                // 다시 들숨으로
                breathingPhase = .inhale
                scale = 1.2
                scheduleNextPhase(after: pattern.inhaleTime)
            }
        }
    }

    private func stopBreathing() {
        timer?.invalidate()
        phaseTimer?.invalidate()
        timer = nil
        phaseTimer = nil
    }
}

// 통증 수준 그래프
struct PainLevelChartView: View {
    let contractions: [Contraction]

    // 통증 수준이 있는 진통만 필터링하고 최근 10개만 표시
    var contractionsWithPain: [Contraction] {
        contractions.filter { $0.painLevel != nil }.prefix(10).reversed()
    }

    var maxPainLevel: Int {
        contractionsWithPain.map { $0.painLevel ?? 0 }.max() ?? 10
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 제목
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.error)

                Text("통증 수준 변화")
                    .font(AppTypography.title3)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                if !contractionsWithPain.isEmpty {
                    Text("\(contractionsWithPain.count)회 기록")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            if contractionsWithPain.isEmpty {
                // 빈 상태
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textSecondary.opacity(0.5))

                    Text("통증 수준 기록이 없습니다")
                        .font(AppTypography.footnote)
                        .foregroundColor(AppColors.textSecondary)

                    Text("진통 중 '아파요' 버튼을 눌러 통증을 기록하세요")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                // 그래프
                VStack(spacing: 8) {
                    // 차트 영역
                    GeometryReader { geometry in
                        ZStack(alignment: .bottomLeading) {
                            // 배경 그리드
                            VStack(spacing: 0) {
                                ForEach(0..<5) { i in
                                    Divider()
                                        .background(AppColors.textSecondary.opacity(0.1))
                                    if i < 4 {
                                        Spacer()
                                    }
                                }
                            }

                            // 라인 차트
                            Path { path in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                let spacing = width / CGFloat(max(contractionsWithPain.count - 1, 1))

                                for (index, contraction) in contractionsWithPain.enumerated() {
                                    let x = CGFloat(index) * spacing
                                    let painLevel = CGFloat(contraction.painLevel ?? 0)
                                    let y = height - (height * painLevel / CGFloat(maxPainLevel + 2))

                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(
                                LinearGradient(
                                    colors: [AppColors.error, AppColors.warning],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                            )

                            // 데이터 포인트
                            ForEach(Array(contractionsWithPain.enumerated()), id: \.element.id) { index, contraction in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                let spacing = width / CGFloat(max(contractionsWithPain.count - 1, 1))
                                let x = CGFloat(index) * spacing
                                let painLevel = CGFloat(contraction.painLevel ?? 0)
                                let y = height - (height * painLevel / CGFloat(maxPainLevel + 2))

                                VStack(spacing: 2) {
                                    // 값 표시
                                    Text("\(contraction.painLevel ?? 0)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(AppColors.error)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(AppColors.error.opacity(0.1))
                                        .cornerRadius(4)

                                    // 포인트 원
                                    Circle()
                                        .fill(AppColors.error)
                                        .frame(width: 8, height: 8)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                }
                                .position(x: x, y: y - 20)
                            }
                        }
                    }
                    .frame(height: 150)

                    // X축 라벨 (시간)
                    HStack {
                        ForEach(Array(contractionsWithPain.enumerated()), id: \.element.id) { index, contraction in
                            if contractionsWithPain.count <= 5 || index % 2 == 0 {
                                Text(formatTime(contraction.timestamp))
                                    .font(.system(size: 9))
                                    .foregroundColor(AppColors.textTertiary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)

                // 범례
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppColors.error)
                            .frame(width: 8, height: 8)
                        Text("통증 수준")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()

                    Text("최고: \(maxPainLevel)회")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.error)
                }
            }
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    ContractionTrackingPhaseView()
        .environmentObject(ContractionManager())
        .environmentObject(AppState())
}
