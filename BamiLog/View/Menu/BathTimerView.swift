//
//  BathTimerView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/13.
//

import SwiftUI

struct BathTimerView: View {
    let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()

    // MARK: View Properties
    @State var counter: Int = 0
    @State var isOver: Bool = false
    @Binding var isBathTimerShow: Bool
    @State var doingBath: Bool = false
    @State var resumeBath: Bool = false
    @State var profile: BabyInfomation?
    var countTo: Int = 600

    var body: some View {
        NavigationStack {
            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    colors: [
                        AppColors.info.opacity(0.1),
                        AppColors.info.opacity(0.05),
                        AppColors.background
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: AppSpacing.xl) {
                    // 상단 타이틀
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.info)

                        Text("\(profile?.name ?? "아기") 목욕 시간")
                            .font(AppTypography.title1)
                            .foregroundColor(AppColors.textPrimary)

                        Text("권장 시간: \(countTo / 60)분")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, AppSpacing.lg)

                    Spacer()

                    // 타이머 원형 디스플레이
                    ZStack {
                        // 배경 트랙
                        Circle()
                            .stroke(AppColors.textSecondary.opacity(0.2), lineWidth: 20)
                            .frame(width: 280, height: 280)

                        // 진행 바
                        Circle()
                            .trim(from: 0, to: progress())
                            .stroke(
                                LinearGradient(
                                    colors: isOver ?
                                        [AppColors.error, AppColors.warning] :
                                        [AppColors.info, AppColors.phase2],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(
                                    lineWidth: 20,
                                    lineCap: .round
                                )
                            )
                            .frame(width: 280, height: 280)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.3), value: counter)

                        // 시간 표시
                        VStack(spacing: AppSpacing.xs) {
                            Text(counterToMinutes())
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(isOver ? AppColors.error : AppColors.textPrimary)

                            Text(isOver ? "시간 초과!" : "남은 시간")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .shadow(color: AppColors.info.opacity(0.2), radius: 20, y: 10)

                    Spacer()

                    // 버튼 영역
                    VStack(spacing: AppSpacing.md) {
                        if !doingBath {
                            // 시작 버튼
                            AppButton(
                                "목욕 시작",
                                icon: "play.fill",
                                color: AppColors.info,
                                fullWidth: true
                            ) {
                                doingBath = true
                                if !resumeBath {
                                    counter = 0
                                }
                            }
                        } else {
                            // 진행 중 버튼들
                            HStack(spacing: AppSpacing.md) {
                                // 일시정지
                                AppButton(
                                    "일시정지",
                                    icon: "pause.fill",
                                    color: AppColors.warning
                                ) {
                                    doingBath = false
                                    resumeBath = true
                                }

                                // 처음부터
                                AppButton(
                                    "처음부터",
                                    icon: "arrow.counterclockwise",
                                    color: AppColors.error
                                ) {
                                    doingBath = false
                                    resumeBath = false
                                    counter = 0
                                    isOver = false
                                }
                            }
                        }

                        // 완료 버튼
                        Button(action: {
                            isBathTimerShow = false
                        }) {
                            Text("완료")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.md)
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isBathTimerShow = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .onReceive(timer) { time in
            if doingBath {
                checkDeadline()
                counter += 1
            }
        }
        .onAppear {
            if (profile?.name.isEmpty) == nil {
                PersitenceManager.retrieveProfile(key: .profile) { result in
                    switch result {
                    case .success(let babyProfile):
                        profile = babyProfile
                    case .failure(_):
                        DispatchQueue.main.async {
                            print("Error profile")
                        }
                    }
                }
            }
        }
    }

    private func checkDeadline() {
        if counter >= countTo {
            isOver = true
        }
    }

    private func progress() -> CGFloat {
        return min(CGFloat(counter) / CGFloat(countTo), 1.0)
    }

    private func counterToMinutes() -> String {
        var currentTime: Int
        if countTo > counter {
            currentTime = countTo - counter
        } else {
            currentTime = counter - countTo
        }

        let seconds = currentTime % 60
        let minutes = Int(currentTime / 60)

        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
}

struct BathTimerView_Previews: PreviewProvider {
    static var previews: some View {
        BathTimerView(isBathTimerShow: .constant(true))
    }
}
