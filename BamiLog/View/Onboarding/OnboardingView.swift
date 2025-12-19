//
//  OnboardingView.swift
//  BamiLog
//
//  Created by Leeo on 11/16/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Environment(\.dismiss) var dismiss

    @State private var currentPage = 0
    @State private var userRole: UserRole = .firstTimeMother
    @State private var motherStatus: MotherStatus = .pregnant
    @State private var babyName: String = ""
    @State private var babyGender: BabyGender = .unknown
    @State private var pregnancyWeeks: Int = 1
    @State private var babyMonths: Int = 0

    var body: some View {
        ZStack {
            // 배경
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.85, blue: 0.95),
                    Color(red: 0.85, green: 0.95, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // 진행 표시
                HStack(spacing: 8) {
                    ForEach(0..<5) { index in
                        Capsule()
                            .fill(currentPage >= index ? Color.cyan : Color.gray.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 60)

                TabView(selection: $currentPage) {
                    // 페이지 1: 환영
                    welcomePage
                        .tag(0)

                    // 페이지 2: 사용자 역할
                    userRolePage
                        .tag(1)

                    // 페이지 3: 엄마 상태
                    motherStatusPage
                        .tag(2)

                    // 페이지 4: 아기 정보
                    babyInfoPage
                        .tag(3)

                    // 페이지 5: 성장 정보
                    growthInfoPage
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }

    // 환영 페이지
    var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "heart.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.pink)

            Text("BamiLog에\n오신 것을 환영합니다")
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            Text("아기와 함께하는 소중한 순간들을\n기록하고 관리해보세요")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)

            Spacer()

            Button(action: {
                withAnimation {
                    currentPage = 1
                }
            }) {
                Text("시작하기")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.cyan)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
        }
    }

    // 사용자 역할 페이지
    var userRolePage: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("누가 사용하시나요?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            VStack(spacing: 16) {
                ForEach(UserRole.allCases, id: \.self) { role in
                    Button(action: {
                        userRole = role
                        // 아빠인 경우 자동으로 출산 완료로 설정
                        if role == .father {
                            motherStatus = .postpartum
                        }
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: role.icon)
                                .font(.system(size: 24))
                                .foregroundColor(userRole == role ? .cyan : .secondary)
                                .frame(width: 40)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(role.rawValue)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.primary)

                                Text(role.description)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if userRole == role {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.cyan)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: userRole == role ? Color.cyan.opacity(0.3) : Color.black.opacity(0.1), radius: 8)
                        )
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            navigationButtons
        }
    }

    // 엄마 상태 페이지
    var motherStatusPage: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("현재 상태는?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            VStack(spacing: 16) {
                ForEach(MotherStatus.allCases, id: \.self) { status in
                    Button(action: {
                        motherStatus = status
                    }) {
                        HStack {
                            Image(systemName: status == .pregnant ? "figure.stand" : "figure.and.child.holdinghands")
                                .font(.system(size: 24))

                            Text(status.rawValue)
                                .font(.system(size: 20, weight: .medium))

                            Spacer()

                            if motherStatus == status {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.cyan)
                            }
                        }
                        .foregroundColor(motherStatus == status ? .cyan : .primary)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: motherStatus == status ? Color.cyan.opacity(0.3) : Color.black.opacity(0.1), radius: 8)
                        )
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            navigationButtons
        }
    }

    // 아기 정보 페이지
    var babyInfoPage: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("아기 정보를 알려주세요")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            VStack(spacing: 24) {
                // 아기 이름
                VStack(alignment: .leading, spacing: 8) {
                    Text("아기 이름 (선택)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)

                    TextField("예: 바미", text: $babyName)
                        .font(.system(size: 18))
                        .padding(16)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                }

                // 성별
                VStack(alignment: .leading, spacing: 8) {
                    Text("성별")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        ForEach(BabyGender.allCases, id: \.self) { gender in
                            Button(action: {
                                babyGender = gender
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: genderIcon(gender))
                                        .font(.system(size: 32))

                                    Text(gender.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(babyGender == gender ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(babyGender == gender ? Color.cyan : Color.white.opacity(0.8))
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            navigationButtons
        }
    }

    // 성장 정보 페이지
    var growthInfoPage: some View {
        VStack(spacing: 32) {
            Spacer()

            Text(motherStatus == .pregnant ? "임신 주차를 알려주세요" : "아기 개월 수를 알려주세요")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 16) {
                if motherStatus == .pregnant {
                    // 임신 주차
                    VStack(spacing: 12) {
                        Text("\(pregnancyWeeks)주차")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.cyan)

                        Picker("주차", selection: $pregnancyWeeks) {
                            ForEach(1...42, id: \.self) { week in
                                Text("\(week)주").tag(week)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 200)
                    }
                } else {
                    // 출산 후 개월 수
                    VStack(spacing: 12) {
                        Text("생후 \(babyMonths)개월")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.cyan)

                        Picker("개월", selection: $babyMonths) {
                            ForEach(0...36, id: \.self) { month in
                                Text("\(month)개월").tag(month)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 200)
                    }
                }
            }

            Spacer()

            Button(action: {
                saveProfile()
            }) {
                Text("완료")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.cyan)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
        }
    }

    // 네비게이션 버튼
    var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentPage > 1 {
                Button(action: {
                    withAnimation {
                        // 아빠이고 페이지 3에서 이전 버튼을 누르면 페이지 1로 이동
                        if userRole == .father && currentPage == 3 {
                            currentPage = 1
                        } else {
                            currentPage -= 1
                        }
                    }
                }) {
                    Text("이전")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.cyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                }
            }

            Button(action: {
                withAnimation {
                    // 아빠이고 페이지 1에서 다음 버튼을 누르면 페이지 2를 건너뛰고 페이지 3으로 이동
                    if userRole == .father && currentPage == 1 {
                        currentPage = 3
                    } else {
                        currentPage += 1
                    }
                }
            }) {
                Text("다음")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.cyan)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 60)
    }

    // 성별 아이콘
    func genderIcon(_ gender: BabyGender) -> String {
        switch gender {
        case .male: return "figure.child"
        case .female: return "figure.child"
        case .unknown: return "questionmark.circle"
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

        userProfileManager.saveProfile(profile)
        dismiss()
    }
}

#Preview {
    OnboardingView()
        .environmentObject(UserProfileManager())
}
