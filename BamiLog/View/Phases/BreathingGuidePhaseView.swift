//
//  BreathingGuidePhaseView.swift
//  BamiLog
//
//  Created by Leeo on 11/16/25.
//

import SwiftUI

struct BreathingGuidePhaseView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var contractionManager: ContractionManager
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var isBreathing = false
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.8
    @State private var breathingText = "시작하기"
    @State private var timer: Timer?
    @State private var smallCircleSize: CGFloat = 150
    @State private var maxCircleSize: CGFloat = 375
    @State private var isCompact: Bool = false

    // 행동 가이드 관련
    @State private var currentPhase: ContractionPhase = .beforeContraction
    @State private var actionMessage: String? = nil
    @State private var showActionMessage = false
    @State private var breathingCycleCount: Int = 0 // 호흡 사이클 카운터

    private let circleWeight: CGFloat = 2.5

    // 더 자연스럽고 대화적인 호흡 가이드 메시지
    private let inhaleStartMessages = [
        "자, 이제 천천히 숨을 들이마셔요",
        "코로 깊게 숨을 들이마시고",
        "편하게 숨을 들이쉬어요",
        "천천히 깊이 들이마셔요",
        "자, 코로 천천히 들이마시고"
    ]

    private let exhaleStartMessages = [
        "좋아요, 이제 천천히 내쉬어요",
        "잘하고 있어요, 천천히 내뱉어요",
        "이제 입으로 편하게 내쉬어요",
        "편안하게 긴장을 풀며 내쉬어요",
        "천천히 입으로 내뱉어요"
    ]

    private let countWords = ["하나", "둘", "셋", "넷", "다섯", "여섯"]

    private let encouragementMessages = [
        "잘하고 있어요",
        "좋아요",
        "편안하게",
        "아주 좋아요",
        "계속 이대로"
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경 그라데이션
                AppColors.gradient2
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 상단 타이틀과 시각화 선택 - 고정 높이
                    VStack(spacing: 8) {
                        HStack {
                            Spacer()

                            VStack(spacing: 6) {
                                Text("호흡 가이드")
                                    .font(isCompact ? AppTypography.title2 : AppTypography.title1)
                                    .foregroundColor(AppColors.textPrimary)

                                Text(visualizationDescription)
                                    .font(isCompact ? AppTypography.footnote : AppTypography.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            Spacer()
                        }

                        // 시각화 타입 선택 버튼
                        HStack(spacing: 12) {
                            ForEach(BreathingVisualization.allCases, id: \.self) { visualization in
                                Button(action: {
                                    contractionManager.saveVisualization(visualization)
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: visualization.icon)
                                            .font(.system(size: 14))
                                        Text(visualization.title)
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(
                                        contractionManager.selectedVisualization == visualization ?
                                        AppColors.textPrimary : AppColors.textSecondary
                                    )
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(
                                                contractionManager.selectedVisualization == visualization ?
                                                AppColors.textPrimary.opacity(0.2) : AppColors.textPrimary.opacity(0.05)
                                            )
                                    )
                                }
                            }
                        }
                    }
                    .frame(height: isCompact ? 100 : 120)
                    .padding(.top, isCompact ? 10 : 20)

                    Spacer()

                    // 호흡 시각화 (원형 또는 촛불)
                    Group {
                        switch contractionManager.selectedVisualization {
                        case .circle:
                            // 원형 호흡
                            ZStack {
                                // 외부 원 (목표 크기) - 더 진하고 두껍게
                                Circle()
                                    .stroke(
                                        AppColors.textPrimary.opacity(0.25),
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [10, 5])
                                    )
                                    .frame(width: maxCircleSize, height: maxCircleSize)

                                // 애니메이션 원
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.cyan.opacity(0.6),
                                                Color.blue.opacity(0.5)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: smallCircleSize, height: smallCircleSize)
                                    .scaleEffect(scale)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.cyan, lineWidth: 4)
                                            .frame(width: smallCircleSize, height: smallCircleSize)
                                            .scaleEffect(scale)
                                    )
                                    .shadow(color: Color.cyan.opacity(0.5), radius: 20, x: 0, y: 0)

                                // 호흡 텍스트
                                Text(breathingText)
                                    .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                    .animation(.easeInOut, value: breathingText)
                            }
                            .frame(height: maxCircleSize)

                        case .candle:
                            // 촛불 호흡
                            CandleBreathingView(
                                isBreathing: isBreathing,
                                breathingText: breathingText,
                                scale: scale,
                                isCompact: isCompact
                            )
                            .frame(height: maxCircleSize)

                        case .paperBoat:
                            // 종이배 호흡
                            PaperBoatBreathingView(
                                isBreathing: isBreathing,
                                breathingText: breathingText,
                                scale: scale,
                                isCompact: isCompact
                            )
                            .frame(height: maxCircleSize)
                        }
                    }
                    .onTapGesture {
                        if isBreathing {
                            stopBreathing()
                        } else {
                            startBreathing()
                        }
                    }

                    Spacer()

                    // 안내 텍스트 - 고정 높이
                    VStack(spacing: 0) {
                        // 상단 메시지 영역 (고정)
                        VStack(spacing: 6) {
                            if !isBreathing {
                                Text("화면을 터치하여 시작하세요")
                                    .font(.system(size: isCompact ? 15 : 17, weight: .medium))
                                    .foregroundColor(AppColors.textPrimary.opacity(0.8))
                                    .transition(.opacity)
                            } else {
                                VStack(spacing: 6) {
                                    Text("편안하게 호흡하세요")
                                        .font(.system(size: isCompact ? 15 : 17, weight: .medium))
                                        .foregroundColor(AppColors.textPrimary.opacity(0.8))

                                    Text("화면을 터치하여 중지")
                                        .font(.system(size: isCompact ? 12 : 13))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .transition(.opacity)
                            }
                        }
                        .frame(height: isCompact ? 50 : 60)
                        .animation(.easeInOut(duration: 0.3), value: isBreathing)

                        // 호흡법 팁 영역 (고정)
                        VStack(spacing: 6) {
                            if !isBreathing {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "lungs")
                                            .font(.system(size: isCompact ? 12 : 14))
                                            .foregroundColor(.cyan)
                                        Text("코로 깊게 들이마시세요")
                                            .font(.system(size: isCompact ? 12 : 13))
                                    }

                                    HStack(spacing: 8) {
                                        Image(systemName: "wind")
                                            .font(.system(size: isCompact ? 12 : 14))
                                            .foregroundColor(.blue)
                                        Text("입으로 천천히 내뱉으세요")
                                            .font(.system(size: isCompact ? 12 : 13))
                                    }
                                }
                                .foregroundColor(AppColors.textSecondary)
                                .padding(isCompact ? 10 : 12)
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                                .transition(.opacity)
                            } else {
                                // 호흡 중일 때도 같은 높이 유지
                                Color.clear
                                    .frame(height: isCompact ? 70 : 80)
                            }
                        }
                        .frame(height: isCompact ? 90 : 100)
                        .animation(.easeInOut(duration: 0.3), value: isBreathing)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, isCompact ? 10 : 20)
                }
            }
            .onAppear {
                let calculatedSize = min(geometry.size.width, geometry.size.height) * 0.25
                smallCircleSize = calculatedSize
                maxCircleSize = calculatedSize * circleWeight
                isCompact = geometry.size.height < 700
            }
            .onChange(of: appState.contractionElapsedTime) { newTime in
                updateActionGuidance()
            }
            .onChange(of: appState.isContracting) { isContracting in
                if !isContracting {
                    // 휴식기 메시지 표시
                    showRestPeriodMessage()
                }
            }
            .overlay(alignment: .top) {
                // 행동 가이드 메시지
                if showActionMessage, let message = actionMessage {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 60)

                        HStack(spacing: 12) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)

                            Text(message)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.orange,
                                    Color.red.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                        .padding(.horizontal, 16)

                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }

    // MARK: - Computed Properties
    private var visualizationDescription: String {
        switch contractionManager.selectedVisualization {
        case .circle:
            return "원을 따라 천천히 호흡하세요"
        case .candle:
            return "촛불을 따라 천천히 호흡하세요"
        case .paperBoat:
            return "종이배를 따라 천천히 호흡하세요"
        }
    }

    // MARK: - Methods
    func startBreathing() {
        isBreathing = true
        breathingText = inhaleStartMessages.randomElement() ?? "자, 이제 천천히 숨을 들이마셔요"

        // 호흡 사이클 카운터 초기화
        breathingCycleCount = 0

        // 호흡 시작 시 첫 가이드 메시지 표시
        showBreathingActionMessage()

        // 선택된 호흡 패턴의 시간 사용
        let pattern = contractionManager.selectedBreathingPattern
        animateBreathing(
            inhaleDuration: pattern.inhaleTime,
            holdDuration: pattern.holdTime,
            exhaleDuration: pattern.exhaleTime
        )
    }

    // 호흡 운동 중 행동 가이드 메시지 표시
    func showBreathingActionMessage() {
        guard let role = userProfileManager.profile?.userRole else { return }

        // 호흡 중 행동 가이드 메시지 가져오기
        let messages: [String]
        switch role {
        case .father:
            messages = [
                "산모의 손을 잡아주세요",
                "산모 곁에 가까이 있어주세요",
                "함께 호흡할 준비를 해주세요",
                "산모의 눈을 바라봐주세요",
                "천천히 함께 호흡해주세요",
                "등을 부드럽게 쓸어주세요"
            ]
        case .firstTimeMother, .experiencedMother:
            messages = [
                "천천히 깊게 숨을 들이마시세요",
                "긴장을 풀고 호흡에 집중하세요",
                "편안한 자세를 찾으세요",
                "계속 천천히 호흡하세요",
                "몸의 힘을 빼고 호흡만 하세요"
            ]
        }

        actionMessage = messages.randomElement()

        if actionMessage != nil {
            withAnimation {
                showActionMessage = true
            }

            // 3초 후 메시지 숨기기
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showActionMessage = false
                }
            }
        }
    }

    func animateBreathing(inhaleDuration: Double, holdDuration: Double, exhaleDuration: Double) {
        // 들숨은 더욱 천천히, 부드럽게 (1.5배 느리게)
        let slowInhaleDuration = inhaleDuration * 1.5
        let inhaleAnimation = Animation.linear(duration: slowInhaleDuration)
        let exhaleAnimation = Animation.easeInOut(duration: exhaleDuration)

        // Start with inhale
        isBreathing = true
        startInhaleGuide()

        withAnimation(inhaleAnimation) {
            scale = circleWeight
            opacity = 0.3
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + slowInhaleDuration) {
            // Hold duration 처리 (있는 경우)
            if holdDuration > 0 {
                breathingText = "숨을 멈추고 잠시 유지하세요"

                DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
                    // Start exhale after hold
                    breathingText = exhaleStartMessages.randomElement() ?? "좋아요, 이제 천천히 내쉬어요"
                    startExhaleGuide()

                    withAnimation(exhaleAnimation) {
                        scale = 1.0
                        opacity = 0.8
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + exhaleDuration) {
                        if isBreathing {
                            // 사이클 카운터 증가
                            breathingCycleCount += 1

                            // 8번에 한 번씩 가이드 메시지 표시
                            if breathingCycleCount % 8 == 0 {
                                showBreathingActionMessage()
                            }

                            // 다음 사이클을 위해 새로운 시작 메시지
                            breathingText = inhaleStartMessages.randomElement() ?? "자, 이제 천천히 숨을 들이마셔요"
                            animateBreathing(inhaleDuration: inhaleDuration, holdDuration: holdDuration, exhaleDuration: exhaleDuration)
                        }
                    }
                }
            } else {
                // Hold 없이 바로 exhale
                breathingText = exhaleStartMessages.randomElement() ?? "좋아요, 이제 천천히 내쉬어요"
                startExhaleGuide()

                withAnimation(exhaleAnimation) {
                    scale = 1.0
                    opacity = 0.8
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + exhaleDuration) {
                    if isBreathing {
                        // 사이클 카운터 증가
                        breathingCycleCount += 1

                        // 8번에 한 번씩 가이드 메시지 표시
                        if breathingCycleCount % 8 == 0 {
                            showBreathingActionMessage()
                        }

                        // 다음 사이클을 위해 새로운 시작 메시지
                        breathingText = inhaleStartMessages.randomElement() ?? "자, 이제 천천히 숨을 들이마셔요"
                        animateBreathing(inhaleDuration: inhaleDuration, holdDuration: holdDuration, exhaleDuration: exhaleDuration)
                    }
                }
            }
        }
    }

    func stopBreathing() {
        isBreathing = false
        timer?.invalidate()
        timer = nil
        withAnimation {
            scale = 1.0
            opacity = 0.8
            breathingText = "시작하기"
        }
    }

    func startInhaleGuide() {
        var counter = 0
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if counter >= 4 {
                t.invalidate()
                return
            }

            // 자연스러운 카운트 표시
            if counter == 0 {
                // 첫 번째는 이미 시작 메시지가 표시되어 있음
            } else if counter < 3 {
                breathingText = countWords[counter - 1] + "..."
            } else {
                // 마지막에 격려 메시지
                breathingText = countWords[counter - 1] + "... " + (encouragementMessages.randomElement() ?? "좋아요")
            }
            counter += 1
        }
    }

    func startExhaleGuide() {
        var counter = 0
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if counter >= 6 {
                t.invalidate()
                return
            }

            // 자연스러운 카운트 표시
            if counter == 0 {
                // 첫 번째는 이미 시작 메시지가 표시되어 있음
            } else if counter < 5 {
                breathingText = countWords[counter - 1] + "..."
            } else {
                // 마지막에 격려 메시지
                breathingText = countWords[counter - 1] + "... " + (encouragementMessages.randomElement() ?? "잘하고 있어요")
            }
            counter += 1
        }
    }

    // 행동 가이드 업데이트
    func updateActionGuidance() {
        guard let role = userProfileManager.profile?.userRole else { return }

        let newPhase = ContractionActionGuide.getCurrentPhase(
            isContracting: appState.isContracting,
            elapsedTime: appState.contractionElapsedTime,
            hasRecentContractions: !contractionManager.contractions.isEmpty
        )

        // 단계가 변경되었고, 메시지를 표시해야 하는 경우
        if newPhase != currentPhase {
            currentPhase = newPhase

            if ContractionActionGuide.shouldShowMessage(for: newPhase, elapsedTime: appState.contractionElapsedTime) {
                actionMessage = ContractionActionGuide.getActionMessage(for: newPhase, userRole: role)

                if actionMessage != nil {
                    withAnimation {
                        showActionMessage = true
                    }

                    // 3초 후 메시지 숨기기
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showActionMessage = false
                        }
                    }
                }
            }
        }
    }

    // 휴식기 메시지 표시
    func showRestPeriodMessage() {
        guard let role = userProfileManager.profile?.userRole else { return }

        currentPhase = .restPeriod
        actionMessage = ContractionActionGuide.getActionMessage(for: .restPeriod, userRole: role)

        if actionMessage != nil {
            withAnimation {
                showActionMessage = true
            }

            // 3초 후 메시지 숨기기
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showActionMessage = false
                }
            }
        }
    }
}

/// 촛불 호흡 애니메이션 컴포넌트
struct CandleBreathingView: View {
    let isBreathing: Bool
    let breathingText: String
    let scale: CGFloat
    let isCompact: Bool

    @State private var flameFlicker: CGFloat = 0
    @State private var flickerTimer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            // 촛불
            VStack(spacing: 0) {
                // 불꽃 영역 (위로 자라는 공간 확보)
                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    ZStack {
                        // 불꽃 (scale에 따라 크기 변화)
                        FlameShape()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        Color.yellow,
                                        Color.orange,
                                        Color.red.opacity(0.8)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 40, height: 60 * scale)
                            .offset(x: flameFlicker * 2)
                            .shadow(color: .orange.opacity(0.6), radius: 20)
                            .shadow(color: .yellow.opacity(0.8), radius: 10)

                        // 불꽃 내부 하이라이트
                        FlameShape()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.9),
                                        Color.yellow.opacity(0.6),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 20, height: 40 * scale)
                            .offset(x: flameFlicker)
                    }
                }
                .frame(height: 120)

                // 심지
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.black.opacity(0.8))
                    .frame(width: 4, height: 15)

                // 초 윗부분 (왁스가 녹은 효과)
                Ellipse()
                    .fill(Color(red: 0.85, green: 0.8, blue: 0.65))
                    .frame(width: 60, height: 12)

                // 초 몸통 (짧게)
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.9, green: 0.85, blue: 0.7),
                                Color(red: 0.95, green: 0.9, blue: 0.75)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
            }
            .frame(height: isCompact ? 230 : 280)

            Spacer()
                .frame(height: 40)

            // 호흡 텍스트
            Text(breathingText)
                .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
                .animation(.easeInOut, value: breathingText)
        }
        .onChange(of: scale) { newScale in
            // 날숨(scale이 작아질 때) 깜빡임 효과
            if newScale < 1.5 {
                startFlickering()
            } else {
                stopFlickering()
            }
        }
        .onDisappear {
            stopFlickering()
        }
    }

    func startFlickering() {
        guard flickerTimer == nil else { return }

        flickerTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                flameFlicker = CGFloat.random(in: -3...3)
            }
        }
    }

    func stopFlickering() {
        flickerTimer?.invalidate()
        flickerTimer = nil
        withAnimation {
            flameFlicker = 0
        }
    }
}

/// 불꽃 모양 Path
struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        // 불꽃 모양 - 더 자연스러운 형태
        path.move(to: CGPoint(x: width * 0.5, y: 0))

        // 오른쪽 상단 곡선
        path.addQuadCurve(
            to: CGPoint(x: width * 0.75, y: height * 0.4),
            control: CGPoint(x: width * 0.7, y: height * 0.15)
        )

        // 오른쪽 중간
        path.addQuadCurve(
            to: CGPoint(x: width * 0.65, y: height * 0.75),
            control: CGPoint(x: width * 0.85, y: height * 0.6)
        )

        // 오른쪽 하단 - 베이스로
        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: height),
            control: CGPoint(x: width * 0.6, y: height * 0.9)
        )

        // 왼쪽 하단 - 베이스에서
        path.addQuadCurve(
            to: CGPoint(x: width * 0.35, y: height * 0.75),
            control: CGPoint(x: width * 0.4, y: height * 0.9)
        )

        // 왼쪽 중간
        path.addQuadCurve(
            to: CGPoint(x: width * 0.25, y: height * 0.4),
            control: CGPoint(x: width * 0.15, y: height * 0.6)
        )

        // 왼쪽 상단 - 다시 정점으로
        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: 0),
            control: CGPoint(x: width * 0.3, y: height * 0.15)
        )

        path.closeSubpath()

        return path
    }
}

/// 종이배 호흡 애니메이션 컴포넌트
struct PaperBoatBreathingView: View {
    let isBreathing: Bool
    let breathingText: String
    let scale: CGFloat
    let isCompact: Bool

    @State private var waveOffset: CGFloat = 0
    @State private var waveTimer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // 종이배와 물결
            ZStack(alignment: .bottom) {
                // 물결 배경
                WaveShape(offset: waveOffset)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.3),
                                Color.cyan.opacity(0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 150)

                WaveShape(offset: waveOffset + 180)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.2),
                                Color.cyan.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 130)

                // 종이배 (scale에 따라 위아래로 움직임)
                PaperBoatShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color.gray.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 60)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    .offset(y: -80 - (scale - 1.0) * 20) // scale에 따라 위아래 이동 (작은 움직임)
            }
            .frame(height: 200)

            Spacer()
                .frame(height: 40)

            // 호흡 텍스트
            Text(breathingText)
                .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
                .animation(.easeInOut, value: breathingText)
        }
        .onAppear {
            startWaveAnimation()
        }
        .onDisappear {
            stopWaveAnimation()
        }
    }

    func startWaveAnimation() {
        waveTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.linear(duration: 0.05)) {
                waveOffset += 2
                if waveOffset > 360 {
                    waveOffset = 0
                }
            }
        }
    }

    func stopWaveAnimation() {
        waveTimer?.invalidate()
        waveTimer = nil
    }
}

/// 물결 모양 Shape
struct WaveShape: Shape {
    var offset: CGFloat

    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let wavelength = width / 2

        path.move(to: CGPoint(x: 0, y: height * 0.5))

        for x in stride(from: 0, through: width, by: 5) {
            let relativeX = x / wavelength
            let sine = sin((relativeX + offset / 180 * .pi))
            let y = height * 0.5 + sine * 10
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}

/// 종이배 모양 Shape
struct PaperBoatShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        // 종이배 모양
        // 왼쪽 아래
        path.move(to: CGPoint(x: 0, y: height))

        // 왼쪽 윗부분
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.2))

        // 중앙 상단 (돛대 끝)
        path.addLine(to: CGPoint(x: width * 0.5, y: 0))

        // 오른쪽 윗부분
        path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.2))

        // 오른쪽 아래
        path.addLine(to: CGPoint(x: width, y: height))

        // 하단 중앙으로 연결 (배 밑면)
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.8))

        path.closeSubpath()

        return path
    }
}

#Preview {
    BreathingGuidePhaseView()
        .environmentObject(AppState())
        .environmentObject(ContractionManager())
        .environmentObject(UserProfileManager())
}
