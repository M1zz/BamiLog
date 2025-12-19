//
//  ProfileEditView.swift
//  BamiLog
//
//  Created by Leeo on 11/16/25.
//

import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Environment(\.dismiss) var dismiss

    @State private var userRole: UserRole
    @State private var motherStatus: MotherStatus
    @State private var babyName: String
    @State private var babyGender: BabyGender
    @State private var pregnancyWeeks: Int
    @State private var babyMonths: Int

    init() {
        // 기본값 설정
        _userRole = State(initialValue: .firstTimeMother)
        _motherStatus = State(initialValue: .pregnant)
        _babyName = State(initialValue: "")
        _babyGender = State(initialValue: .unknown)
        _pregnancyWeeks = State(initialValue: 1)
        _babyMonths = State(initialValue: 0)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 배경
                AppColors.gradient1
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 사용자 역할
                        VStack(alignment: .leading, spacing: 12) {
                            Text("사용자 역할")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)

                            VStack(spacing: 12) {
                                ForEach(UserRole.allCases, id: \.self) { role in
                                    Button(action: {
                                        userRole = role
                                        // 아빠인 경우 출산 완료로 자동 설정
                                        if role == .father {
                                            motherStatus = .postpartum
                                        }
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: role.icon)
                                                .font(.system(size: 20))
                                                .foregroundColor(userRole == role ? .cyan : AppColors.textSecondary)
                                                .frame(width: 40)

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(role.rawValue)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(AppColors.textPrimary)

                                                Text(role.description)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(AppColors.textSecondary)
                                            }

                                            Spacer()

                                            if userRole == role {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 22))
                                                    .foregroundColor(.cyan)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(userRole == role ? Color.cyan.opacity(0.2) : AppColors.cardBackground)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(userRole == role ? Color.cyan : Color.clear, lineWidth: 2)
                                                )
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        // 엄마 상태 (산모인 경우만 표시)
                        if userRole.isMotherRole {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("임신 상태")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)

                                HStack(spacing: 12) {
                                    ForEach(MotherStatus.allCases, id: \.self) { status in
                                        Button(action: {
                                            motherStatus = status
                                        }) {
                                            HStack {
                                                Image(systemName: status == .pregnant ? "figure.stand" : "figure.and.child.holdinghands")
                                                    .font(.system(size: 18))

                                                Text(status.rawValue)
                                                    .font(.system(size: 16, weight: .medium))
                                            }
                                            .foregroundColor(motherStatus == status ? .cyan : AppColors.textPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(motherStatus == status ? Color.cyan.opacity(0.2) : AppColors.cardBackground)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(motherStatus == status ? Color.cyan : Color.clear, lineWidth: 2)
                                                    )
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // 아기 이름
                        VStack(alignment: .leading, spacing: 12) {
                            Text("아기 이름 (선택)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)

                            TextField("예: 바미", text: $babyName)
                                .font(.system(size: 16))
                                .padding(16)
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(.horizontal, 16)

                        // 성별
                        VStack(alignment: .leading, spacing: 12) {
                            Text("성별")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)

                            HStack(spacing: 12) {
                                ForEach(BabyGender.allCases, id: \.self) { gender in
                                    Button(action: {
                                        babyGender = gender
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: genderIcon(gender))
                                                .font(.system(size: 24))

                                            Text(gender.rawValue)
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(babyGender == gender ? .cyan : AppColors.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(babyGender == gender ? Color.cyan.opacity(0.2) : AppColors.cardBackground)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(babyGender == gender ? Color.cyan : Color.clear, lineWidth: 2)
                                                )
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        // 성장 정보
                        VStack(alignment: .leading, spacing: 12) {
                            Text(motherStatus == .pregnant ? "임신 주차" : "아기 개월 수")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)

                            if motherStatus == .pregnant {
                                VStack(spacing: 8) {
                                    Text("\(pregnancyWeeks)주차")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.cyan)

                                    Picker("주차", selection: $pregnancyWeeks) {
                                        ForEach(1...42, id: \.self) { week in
                                            Text("\(week)주").tag(week)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 150)
                                }
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                            } else {
                                VStack(spacing: 8) {
                                    Text("생후 \(babyMonths)개월")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.cyan)

                                    Picker("개월", selection: $babyMonths) {
                                        ForEach(0...36, id: \.self) { month in
                                            Text("\(month)개월").tag(month)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 150)
                                }
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("프로필 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveProfile()
                    }
                    .foregroundColor(.cyan)
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
        }
    }

    // 성별 아이콘
    func genderIcon(_ gender: BabyGender) -> String {
        switch gender {
        case .male: return "figure.child"
        case .female: return "figure.child"
        case .unknown: return "questionmark.circle"
        }
    }

    // 현재 프로필 로드
    func loadCurrentProfile() {
        if let profile = userProfileManager.profile {
            userRole = profile.userRole
            motherStatus = profile.motherStatus
            babyName = profile.babyName ?? ""
            babyGender = profile.babyGender

            if let growth = profile.growthStage {
                switch growth {
                case .pregnant(let weeks):
                    pregnancyWeeks = weeks
                case .postpartum(let months):
                    babyMonths = months
                }
            }
        }
    }

    // 프로필 저장
    func saveProfile() {
        let growthStage: GrowthStage? = motherStatus == .pregnant ?
            .pregnant(weeks: pregnancyWeeks) :
            .postpartum(months: babyMonths)

        let profile = UserProfile(
            userRole: userRole,
            motherStatus: motherStatus,
            babyName: babyName.isEmpty ? nil : babyName,
            babyGender: babyGender,
            growthStage: growthStage
        )

        userProfileManager.updateProfile(profile)
        dismiss()
    }
}

#Preview {
    ProfileEditView()
        .environmentObject(UserProfileManager())
}
