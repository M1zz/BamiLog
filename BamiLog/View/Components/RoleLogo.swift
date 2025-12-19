//
//  RoleLogo.swift
//  BamiLog
//
//  Created by Leeo on 11/17/25.
//

import SwiftUI

/// 사용자 역할에 따라 다른 로고를 표시하는 컴포넌트
struct RoleLogo: View {
    let role: UserRole
    let size: CGFloat
    let showText: Bool

    init(role: UserRole, size: CGFloat = 80, showText: Bool = true) {
        self.role = role
        self.size = size
        self.showText = showText
    }

    // 역할별 색상 그라데이션
    var roleGradient: LinearGradient {
        switch role {
        case .firstTimeMother:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.4, blue: 0.6),
                    Color(red: 1.0, green: 0.6, blue: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .experiencedMother:
            return LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.4, blue: 0.8),
                    Color(red: 0.8, green: 0.6, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .father:
            return LinearGradient(
                colors: [
                    Color(red: 0.3, green: 0.6, blue: 1.0),
                    Color(red: 0.5, green: 0.8, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // 역할별 보조 색상
    var secondaryColor: Color {
        switch role {
        case .firstTimeMother:
            return Color(red: 1.0, green: 0.7, blue: 0.8)
        case .experiencedMother:
            return Color(red: 0.9, green: 0.7, blue: 1.0)
        case .father:
            return Color(red: 0.6, green: 0.9, blue: 1.0)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // 배경 원
                Circle()
                    .fill(roleGradient)
                    .frame(width: size, height: size)
                    .shadow(color: secondaryColor.opacity(0.4), radius: 10)

                // 아이콘
                Image(systemName: role.icon)
                    .font(.system(size: size * 0.45, weight: .semibold))
                    .foregroundColor(.white)

                // 장식 링
                Circle()
                    .stroke(secondaryColor.opacity(0.3), lineWidth: 3)
                    .frame(width: size * 1.2, height: size * 1.2)
            }

            if showText {
                VStack(spacing: 4) {
                    Text(role.rawValue)
                        .font(.system(size: size * 0.2, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)

                    Text(role.description)
                        .font(.system(size: size * 0.12))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

/// 현재 사용자의 역할 로고
struct CurrentUserLogo: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    let size: CGFloat
    let showText: Bool

    init(size: CGFloat = 80, showText: Bool = true) {
        self.size = size
        self.showText = showText
    }

    var body: some View {
        if let profile = userProfileManager.profile {
            RoleLogo(role: profile.userRole, size: size, showText: showText)
        } else {
            // 기본 로고
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size, height: size)

                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: size * 0.45, weight: .semibold))
                        .foregroundColor(.gray)
                }

                if showText {
                    Text("BamiLog")
                        .font(.system(size: size * 0.2, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        Text("역할별 로고")
            .font(.headline)

        HStack(spacing: 30) {
            VStack {
                RoleLogo(role: .firstTimeMother, size: 80)
            }

            VStack {
                RoleLogo(role: .experiencedMother, size: 80)
            }

            VStack {
                RoleLogo(role: .father, size: 80)
            }
        }

        Divider()

        Text("로고만 (텍스트 없이)")
            .font(.headline)

        HStack(spacing: 30) {
            RoleLogo(role: .firstTimeMother, size: 60, showText: false)
            RoleLogo(role: .experiencedMother, size: 60, showText: false)
            RoleLogo(role: .father, size: 60, showText: false)
        }
    }
    .padding()
}
