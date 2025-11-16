//
//  MenuView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/01.
//  Updated with unified design system
//

import SwiftUI

enum ButtonType {
    case milk
    case feeding
    case diaper
    case sleep
}

struct MenuView: View {

    @State var profile: BabyInfomation?

    /// - View 내부에 정의된 상수를 연산 프로퍼티로 변경
    var diff: DateComponents {
        Calendar.current.dateComponents([.day], from: profile?.birthDate ?? Date() , to: Date())
    }

    // MARK: View Properties
    @State var isShow: Bool = false
    @State var isTableShow: Bool = false
    @State var isEnterProfile: Bool = false
    @State var isBathTimerShow: Bool = false
    @State var isSoundViewShow: Bool = false
    @State var buttonType: ButtonType?

    @State var showLoginPage: Bool = false
    @AppStorage("loginStatus") var loginStatus = false

    var body: some View {
        NavigationStack {
            ZStack {
                // 배경
                AppColors.gradient1
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        // MARK: Header - Profile Card
                        profileCard
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.top, AppSpacing.sm)

                        // MARK: 기능 섹션
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            SectionHeader("아기 돌봄")
                                .padding(.horizontal, AppSpacing.md)

                            // 수유 섹션
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: AppSpacing.md),
                                GridItem(.flexible(), spacing: AppSpacing.md),
                                GridItem(.flexible(), spacing: AppSpacing.md)
                            ], spacing: AppSpacing.md) {
                                // 분유 수유
                                MenuIconButton(
                                    icon: "bottle.fill",
                                    label: "분유",
                                    color: AppColors.warning
                                ) {
                                    buttonType = .milk
                                    isShow.toggle()
                                }

                                // 모유 수유
                                MenuIconButton(
                                    icon: "heart.circle.fill",
                                    label: "모유",
                                    color: Color(red: 0.9, green: 0.6, blue: 0.8)
                                ) {
                                    buttonType = .feeding
                                    isShow.toggle()
                                }

                                // 수면
                                MenuIconButton(
                                    icon: "moon.stars.fill",
                                    label: "수면",
                                    color: Color(red: 0.5, green: 0.6, blue: 0.9)
                                ) {
                                    buttonType = .sleep
                                    isShow.toggle()
                                }

                                // 기저귀
                                MenuIconButton(
                                    icon: "squareshape.fill",
                                    label: "기저귀",
                                    color: Color(red: 0.7, green: 0.5, blue: 0.4)
                                ) {
                                    buttonType = .diaper
                                    isShow.toggle()
                                }

                                // 목욕
                                MenuIconButton(
                                    icon: "drop.fill",
                                    label: "목욕",
                                    color: AppColors.info
                                ) {
                                    isBathTimerShow.toggle()
                                }

                                // 소리
                                MenuIconButton(
                                    icon: "music.note",
                                    label: "자장가",
                                    color: Color(red: 0.8, green: 0.7, blue: 0.9)
                                ) {
                                    isSoundViewShow.toggle()
                                }
                            }
                            .padding(.horizontal, AppSpacing.md)

                            // 기록 보기 버튼
                            VStack(spacing: AppSpacing.sm) {
                                AppButton(
                                    "기록 보기",
                                    icon: "chart.bar.fill",
                                    color: AppColors.phase3,
                                    fullWidth: true
                                ) {
                                    isTableShow.toggle()
                                }
                            }
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.top, AppSpacing.sm)
                        }

                        Spacer(minLength: AppSpacing.xl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        CoworkView(showLoginPage: $showLoginPage)
                    } label: {
                        Image(systemName: "person.2.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $isShow) {
            RecordView(buttonType: $buttonType, isShow: $isShow)
        }
        .sheet(isPresented: $isTableShow) {
            StaticsView(isTableShow: $isTableShow)
        }
        .sheet(isPresented: $isBathTimerShow) {
            BathTimerView(isBathTimerShow: $isBathTimerShow)
        }
        .fullScreenCover(isPresented: $isSoundViewShow) {
            SoundView(isSoundViewShow: $isSoundViewShow)
        }
        .sheet(isPresented: $isEnterProfile, onDismiss: {
            if (profile?.name.isEmpty) == nil {
                PersitenceManager.retrieveProfile(key: .profile) { result in
                    switch result {
                    case .success(let babyProfile):
                        profile = babyProfile
                    case .failure(_):
                        DispatchQueue.main.async {
                            isEnterProfile = true
                            print("Error profile")
                        }
                    }
                }
            }
        }, content: {
            EnterProfileView(isEnterProfile: $isEnterProfile)
        })
        .onAppear {
            if (profile?.name.isEmpty) == nil {
                PersitenceManager.retrieveProfile(key: .profile) { result in
                    switch result {
                    case .success(let babyProfile):
                        profile = babyProfile
                    case .failure(_):
                        DispatchQueue.main.async {
                            isEnterProfile = true
                            print("Error profile")
                        }
                    }
                }
            }

            loginStatus = UserDefaults.standard.bool(forKey: "loginStatus")
        }
    }

    // MARK: - Profile Card
    @ViewBuilder
    private var profileCard: some View {
        AppCard {
            if let profile {
                VStack(spacing: AppSpacing.sm) {
                    HStack {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(profile.name)
                                .font(AppTypography.title1)
                                .foregroundColor(AppColors.textPrimary)

                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textSecondary)
                                Text("태어난 지 \(diff.day?.description ?? "0")일째")
                                    .font(AppTypography.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }

                        Spacer()

                        // 아기 아이콘
                        ZStack {
                            Circle()
                                .fill(AppColors.phase3.opacity(0.2))
                                .frame(width: 60, height: 60)

                            Image(systemName: "figure.and.child.holdinghands")
                                .font(.system(size: 30))
                                .foregroundColor(AppColors.phase3)
                        }
                    }

                    Divider()
                        .padding(.vertical, AppSpacing.xs)

                    HStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.warning)

                        Text("기적의 100일까지 \((100 - (diff.day ?? 0)).description)일")
                            .font(AppTypography.callout)
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()
                    }
                }
            } else {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textSecondary)

                    Text("아기의 이름과 태어난 날을 입력해주세요")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
            }
        }
    }
}

// MARK: - Menu Icon Button Component
struct MenuIconButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 70, height: 70)

                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 60, height: 60)

                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(color)
                }

                Text(label)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(profile: BabyInfomation(name: "아키", birthDate: Date()), buttonType: .milk, showLoginPage: false)
    }
}
