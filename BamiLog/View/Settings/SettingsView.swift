//
//  SettingsView.swift
//  BamiLog
//
//  Created by Leeo on 11/16/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var contractionManager: ContractionManager
    @EnvironmentObject var userProfileManager: UserProfileManager

    @State private var showDeleteAlert = false
    @State private var showLogView = false
    @State private var showProfileEdit = false

    // 역할에 따른 아이콘
    var roleIcon: String {
        guard let profile = userProfileManager.profile else {
            return "person.circle.fill"
        }
        return profile.userRole.icon
    }

    // 역할에 따른 색상
    var roleColor: Color {
        guard let profile = userProfileManager.profile else {
            return .gray
        }

        switch profile.userRole {
        case .firstTimeMother:
            return Color(red: 1.0, green: 0.4, blue: 0.6) // 핑크
        case .experiencedMother:
            return Color(red: 0.6, green: 0.4, blue: 0.8) // 보라
        case .father:
            return Color(red: 0.3, green: 0.6, blue: 1.0) // 파랑
        }
    }

    // 역할에 따른 배경 색상
    var roleBackgroundColor: Color {
        return roleColor
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 배경 그라데이션
                AppColors.gradient1
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 사용자 정보 섹션
                        VStack(alignment: .leading, spacing: 12) {
                            Text("사용자 정보")
                                .font(AppTypography.title3)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal, 16)

                            Button(action: {
                                showProfileEdit = true
                            }) {
                                HStack(spacing: 12) {
                                    // 역할에 따라 다른 아이콘과 색상 표시
                                    ZStack {
                                        Circle()
                                            .fill(roleBackgroundColor.opacity(0.2))
                                            .frame(width: 50, height: 50)

                                        Image(systemName: roleIcon)
                                            .font(.system(size: 24))
                                            .foregroundColor(roleColor)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        if let profile = userProfileManager.profile {
                                            Text(profile.babyName ?? "아기 정보")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(AppColors.textPrimary)

                                            HStack(spacing: 8) {
                                                Text(profile.userRole.rawValue)
                                                if profile.userRole.isMotherRole {
                                                    Text("•")
                                                    Text(profile.motherStatus.rawValue)
                                                }
                                                if let growth = profile.growthStage {
                                                    Text("•")
                                                    Text(growth.description)
                                                }
                                            }
                                            .font(.system(size: 12))
                                            .foregroundColor(AppColors.textSecondary)
                                        } else {
                                            Text("프로필 설정하기")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(AppColors.textPrimary)

                                            Text("사용자 정보를 입력해주세요")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppColors.textSecondary)
                                        }
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding(16)
                                .background(AppColors.cardBackground)
                                .cornerRadius(14)
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 20)

                        // 아기 프로필 섹션 (Phase 3에서만 표시)
                        if appState.currentPhase == .babyCare {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("아기 정보")
                                    .font(AppTypography.title3)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal, 16)

                                SettingsBabyProfileCard()
                                    .padding(.horizontal, 16)
                            }
                            .padding(.top, 20)
                        }

                        // 페이즈 선택 섹션
                        VStack(alignment: .leading, spacing: 12) {
                            Text("현재 단계")
                                .font(AppTypography.title3)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal, 16)

                            Text("출산 과정의 단계를 선택하세요")
                                .font(AppTypography.footnote)
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.horizontal, 16)

                            VStack(spacing: 12) {
                                ForEach(AppPhase.allCases) { phase in
                                    PhaseSelectionCard(
                                        phase: phase,
                                        isSelected: appState.currentPhase == phase,
                                        action: {
                                            appState.currentPhase = phase
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 20)

                        // 호흡 설정 섹션
                        VStack(alignment: .leading, spacing: 12) {
                            Text("호흡 가이드")
                                .font(AppTypography.title3)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal, 16)

                            Text("진통 중 사용할 호흡 패턴을 선택하세요")
                                .font(AppTypography.footnote)
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.horizontal, 16)

                            VStack(spacing: 12) {
                                ForEach(BreathingPattern.allCases, id: \.self) { pattern in
                                    BreathingPatternCard(
                                        pattern: pattern,
                                        isSelected: contractionManager.selectedBreathingPattern == pattern,
                                        action: {
                                            contractionManager.saveBreathingPattern(pattern)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 20)

                        // 데이터 관리 섹션
                        VStack(alignment: .leading, spacing: 12) {
                            Text("데이터 관리")
                                .font(AppTypography.title3)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal, 16)

                            VStack(spacing: 12) {
                                // 로그 보기 버튼
                                Button(action: {
                                    showLogView = true
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "doc.text.magnifyingglass")
                                            .font(.system(size: 20))
                                            .foregroundColor(.cyan)
                                            .frame(width: 40)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("로그 보기")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(AppColors.textPrimary)

                                            Text("진통 기록과 상세 정보를 확인합니다")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppColors.textSecondary)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .padding(16)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(14)
                                }

                                // 진통 타이머 중지 버튼 (진행 중일 때만 표시)
                                if contractionManager.isContractionInProgress {
                                    Button(action: {
                                        contractionManager.cancelContraction()
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "stop.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(.orange)
                                                .frame(width: 40)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("진통 타이머 중지")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(AppColors.textPrimary)

                                                Text("진행 중인 진통 타이머를 중지합니다")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AppColors.textSecondary)
                                            }

                                            Spacer()
                                        }
                                        .padding(16)
                                        .background(Color.orange.opacity(0.15))
                                        .cornerRadius(14)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                }

                                // 진통 기록 초기화 버튼
                                Button(action: {
                                    showDeleteAlert = true
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.red)
                                            .frame(width: 40)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("진통 기록 초기화")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(AppColors.textPrimary)

                                            Text("모든 진통 기록을 삭제합니다")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppColors.textSecondary)
                                        }

                                        Spacer()
                                    }
                                    .padding(16)
                                    .background(Color.red.opacity(0.15))
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
            .sheet(isPresented: $showLogView) {
                LogView()
                    .environmentObject(contractionManager)
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showProfileEdit) {
                ProfileEditView()
                    .environmentObject(userProfileManager)
            }
            .alert("진통 기록 삭제", isPresented: $showDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    contractionManager.deleteAllContractions()
                }
            } message: {
                Text("모든 기록을 삭제할까요?\n되돌릴 수 없습니다.")
            }
        }
    }
}

struct PhaseSelectionCard: View {
    let phase: AppPhase
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 아이콘
                Image(systemName: phase.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .cyan : AppColors.textSecondary)
                    .frame(width: 40)

                // 텍스트
                VStack(alignment: .leading, spacing: 4) {
                    Text(phase.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    Text(phase.description)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // 선택 표시
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.cyan)
                }
            }
            .padding(16)
            .background(
                isSelected ? Color.cyan.opacity(0.2) : AppColors.cardBackground
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct BreathingPatternCard: View {
    let pattern: BreathingPattern
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 아이콘
                Image(systemName: "wind")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .cyan : AppColors.textSecondary)
                    .frame(width: 40)

                // 텍스트
                VStack(alignment: .leading, spacing: 4) {
                    Text(pattern.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    Text(pattern.description)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // 선택 표시
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.cyan)
                }
            }
            .padding(16)
            .background(
                isSelected ? Color.cyan.opacity(0.2) : AppColors.cardBackground
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Baby Profile Card
struct SettingsBabyProfileCard: View {
    @State private var profile: BabyInfomation?
    @State private var isEnterProfile = false

    var diff: DateComponents {
        guard let birthDate = profile?.birthDate else { return DateComponents() }
        return Calendar.current.dateComponents([.day], from: birthDate, to: Date())
    }

    var body: some View {
        Button(action: {
            isEnterProfile = true
        }) {
            HStack(spacing: 12) {
                // 아기 아이콘
                ZStack {
                    Circle()
                        .fill(AppColors.phase3.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: "figure.and.child.holdinghands")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.phase3)
                }

                if let profile = profile {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)

                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                            Text("태어난 지 \(diff.day?.description ?? "0")일째")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(AppColors.textSecondary)

                        if let daysTo100 = diff.day, daysTo100 < 100 {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColors.warning)
                                Text("기적의 100일까지 \((100 - daysTo100).description)일")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("아기 정보 입력하기")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)

                        Text("아기의 이름과 태어난 날을 입력해주세요")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(16)
            .background(AppColors.cardBackground)
            .cornerRadius(14)
        }
        .onAppear {
            loadProfile()
        }
        .sheet(isPresented: $isEnterProfile, onDismiss: {
            loadProfile()
        }) {
            EnterProfileView(isEnterProfile: $isEnterProfile)
        }
    }

    func loadProfile() {
        PersitenceManager.retrieveProfile(key: .profile) { result in
            switch result {
            case .success(let babyProfile):
                profile = babyProfile
            case .failure(_):
                profile = nil
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(ContractionManager())
        .environmentObject(UserProfileManager())
}
