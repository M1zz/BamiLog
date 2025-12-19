//
//  MainView.swift
//  laborBreath
//
//  Created by Claude on 11/14/24.
//

import SwiftUI

struct MainView: View {
    @StateObject private var appState = AppState()
    @StateObject private var contractionManager = ContractionManager()
    @StateObject private var userProfileManager = UserProfileManager()
    @StateObject private var menstrualManager = MenstrualCycleManager()
    @StateObject private var pregnancyManager = PregnancyManager()

    var body: some View {
        Group {
            // 온보딩 확인
            if !userProfileManager.hasCompletedOnboarding {
                OnboardingView()
                    .environmentObject(userProfileManager)
            } else {
                mainContent
            }
        }
    }

    @ViewBuilder
    var mainContent: some View {
        Group {
            // 현재 페이즈에 따른 화면 표시
            switch appState.currentPhase {
            case .menstrualTracking:
                // 페이즈 1: 생리 주기 추적
                MenstrualTrackingPhaseView()
                    .environmentObject(menstrualManager)
                    .environmentObject(appState)
                    .environmentObject(userProfileManager)

            case .pregnancy:
                // 페이즈 2: 임신 정보
                PregnancyPhaseView()
                    .environmentObject(pregnancyManager)
                    .environmentObject(appState)
                    .environmentObject(userProfileManager)

            case .laborAndBirth:
                // 페이즈 3: 진통 & 호흡 가이드
                LaborAndBreathingPhaseView()
                    .environmentObject(contractionManager)
                    .environmentObject(appState)
                    .environmentObject(userProfileManager)

            case .babyCare:
                // 페이즈 4: 아기 돌봄 (MenuView는 자체 NavigationStack 포함)
                MenuView()
                    .environmentObject(appState)

            case .growthDiary:
                // 페이즈 5: 성장 기록
                GrowthDiaryPhaseView()
                    .environmentObject(appState)
            }
        }
        .onAppear {
            // UserProfile의 임신 정보와 PregnancyManager 동기화
            pregnancyManager.syncWithUserProfile(userProfileManager.profile)
        }
        // 모든 페이즈에서 공통으로 사용하는 Settings Sheet
        .sheet(isPresented: $appState.showSettings) {
            SettingsView()
                .environmentObject(appState)
                .environmentObject(contractionManager)
                .environmentObject(userProfileManager)
                .environmentObject(menstrualManager)
                .environmentObject(pregnancyManager)
        }
    }
}

// MARK: - Placeholder for Phase 4
struct PlaceholderPhase4View: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        AppColors.phase2.opacity(0.1),
                        AppColors.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        Spacer(minLength: 60)

                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.phase2)

                        Text("Phase 4: 성장 기록")
                            .font(AppTypography.title1)
                            .foregroundColor(AppColors.textPrimary)

                        Text("파일을 Xcode 프로젝트에 추가해주세요")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)

                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("📋 추가 방법:")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)

                            InstructionRow(number: "1", text: "Xcode에서 File → Add Files to \"BamiLog\"...")
                            InstructionRow(number: "2", text: "BamiLog/View/GrowthDiary 폴더 선택")
                            InstructionRow(number: "3", text: "Options: Copy items 체크 해제, Create groups 선택")
                            InstructionRow(number: "4", text: "Add 클릭")
                            InstructionRow(number: "5", text: "같은 방법으로 GrowthModels.swift와 GrowthDiaryPhaseView.swift 추가")
                            InstructionRow(number: "6", text: "MainView.swift에서 PlaceholderPhase4View를 GrowthDiaryPhaseView로 변경")
                        }
                        .padding(AppSpacing.lg)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppRadius.lg)

                        Button(action: {
                            appState.currentPhase = .babyCare
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Phase 3로 돌아가기")
                            }
                            .font(AppTypography.body)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.phase2)
                            .cornerRadius(AppRadius.md)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        appState.showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(AppColors.phase2)
                .cornerRadius(12)

            Text(text)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

#Preview {
    MainView()
}
