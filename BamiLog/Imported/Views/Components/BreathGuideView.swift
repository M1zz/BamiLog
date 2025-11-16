//
//  BreathGuideView.swift
//  laborBreath
//
//  Created by Claude on 11/14/24.
//

import SwiftUI

struct BreathGuideView: View {
    @State private var isBreathing = false
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.8
    @State private var breathingText = "시작하기"
    @State private var timer: Timer?
    @State private var currentInhaleMessage = "들이마시고"
    @State private var currentExhaleMessage = "내쉬고"

    @State private var smallCircleSize: CGFloat = 150
    @State private var maxCircleSize: CGFloat = 375
    @State private var isCompact: Bool = false

    private let circleWeight: CGFloat = 2.5

    private let inhaleMessages = ["들이마시고", "마시면서", "숨을 들이쉬며", "천천히 들숨", "깊게 들이마시고"]
    private let exhaleMessages = ["내쉬고", "내쉬자", "숨을 내쉬며", "천천히 날숨", "편하게 내쉬자"]

    var body: some View {
        GeometryReader { geometry in

            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.15, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: isCompact ? 12 : 20) {
                    // 상단 타이틀
                    VStack(spacing: 6) {
                        Text("호흡 가이드")
                            .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("원을 따라 천천히 호흡하세요")
                            .font(.system(size: isCompact ? 13 : 15))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, isCompact ? 10 : 20)

                    Spacer(minLength: 0)

                    // 호흡 원
                    ZStack {
                        // 외부 원 (목표 크기)
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: maxCircleSize, height: maxCircleSize)

                        // 애니메이션 원
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(opacity), Color.cyan.opacity(opacity * 0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: smallCircleSize, height: smallCircleSize)
                            .scaleEffect(scale)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: smallCircleSize, height: smallCircleSize)
                                    .scaleEffect(scale)
                            )

                        // 호흡 텍스트
                        Text(breathingText)
                            .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
                            .foregroundColor(.white)
                            .animation(.easeInOut, value: breathingText)
                    }
                    .frame(height: maxCircleSize)
                    .onTapGesture {
                        if isBreathing {
                            stopBreathing()
                        } else {
                            startBreathing()
                        }
                    }

                    Spacer(minLength: 0)

                    // 안내 텍스트
                    VStack(spacing: isCompact ? 8 : 12) {
                        if !isBreathing {
                            Text("원을 터치하여 시작하세요")
                                .font(.system(size: isCompact ? 15 : 17, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        } else {
                            VStack(spacing: 6) {
                                Text("원을 따라 편안하게 호흡하세요")
                                    .font(.system(size: isCompact ? 15 : 17, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))

                                Text("원을 터치하여 중지")
                                    .font(.system(size: isCompact ? 12 : 13))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }

                        // 호흡법 팁
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
                            .foregroundColor(.white.opacity(0.7))
                            .padding(isCompact ? 10 : 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
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
        }
    }

    func startBreathing() {
        isBreathing = true
        // 랜덤 메시지 선택
        currentInhaleMessage = inhaleMessages.randomElement() ?? "들이마시고"
        currentExhaleMessage = exhaleMessages.randomElement() ?? "내쉬고"
        breathingText = currentInhaleMessage

        animateBreathing(inhaleDuration: 4.0, exhaleDuration: 6.0)
    }

    func animateBreathing(inhaleDuration: Double, exhaleDuration: Double) {
        let inhaleAnimation = Animation.easeInOut(duration: inhaleDuration)
        let exhaleAnimation = Animation.easeInOut(duration: exhaleDuration)

        // Start with inhale
        isBreathing = true
        isTimerRunning(isInhaling: true)

        withAnimation(inhaleAnimation) {
            scale = circleWeight
            opacity = 0.3
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleDuration) {
            // Start exhale after inhale
            breathingText = currentExhaleMessage
            isTimerRunning(isInhaling: false)

            withAnimation(exhaleAnimation) {
                scale = 1.0
                opacity = 0.8
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + exhaleDuration) {
                if isBreathing {
                    // 다음 사이클을 위해 새로운 랜덤 메시지 선택
                    currentInhaleMessage = inhaleMessages.randomElement() ?? "들이마시고"
                    currentExhaleMessage = exhaleMessages.randomElement() ?? "내쉬고"
                    breathingText = currentInhaleMessage
                    animateBreathing(inhaleDuration: inhaleDuration, exhaleDuration: exhaleDuration)
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

    func isTimerRunning(isInhaling: Bool) {
        let totalDuration = isInhaling ? 4 : 6
        var counter = 1

        timer?.invalidate() // Clear any previous timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if counter > totalDuration {
                t.invalidate()
                return
            }

            // Update text based on inhale or exhale phase with random message
            breathingText = isInhaling ? "\(currentInhaleMessage) \(counter)" : "\(currentExhaleMessage) \(counter)"
            counter += 1
        }
    }
}

#Preview {
    BreathGuideView()
}
