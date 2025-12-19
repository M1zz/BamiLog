//
//  UserRoleIcon.swift
//  BamiLog
//
//  Created by Leeo on 11/16/25.
//

import SwiftUI

/// 사용자 역할에 따라 다른 아이콘을 표시하는 컴포넌트
struct UserRoleIcon: View {
    let role: UserRole
    let size: CGFloat
    let showBackground: Bool

    init(role: UserRole, size: CGFloat = 40, showBackground: Bool = true) {
        self.role = role
        self.size = size
        self.showBackground = showBackground
    }

    /// 역할별 색상
    var roleColor: Color {
        switch role {
        case .firstTimeMother:
            return Color(red: 1.0, green: 0.4, blue: 0.6) // 핑크
        case .experiencedMother:
            return Color(red: 0.6, green: 0.4, blue: 0.8) // 보라
        case .father:
            return Color(red: 0.3, green: 0.6, blue: 1.0) // 파랑
        }
    }

    var body: some View {
        ZStack {
            if showBackground {
                Circle()
                    .fill(roleColor.opacity(0.2))
                    .frame(width: size * 1.5, height: size * 1.5)
            }

            Image(systemName: role.icon)
                .font(.system(size: size))
                .foregroundColor(roleColor)
        }
    }
}

/// UserProfileManager에서 직접 현재 사용자 아이콘을 표시하는 컴포넌트
struct CurrentUserRoleIcon: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    let size: CGFloat
    let showBackground: Bool

    init(size: CGFloat = 40, showBackground: Bool = true) {
        self.size = size
        self.showBackground = showBackground
    }

    var body: some View {
        if let profile = userProfileManager.profile {
            UserRoleIcon(
                role: profile.userRole,
                size: size,
                showBackground: showBackground
            )
        } else {
            // 프로필이 없을 때 기본 아이콘
            ZStack {
                if showBackground {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: size * 1.5, height: size * 1.5)
                }

                Image(systemName: "person.circle.fill")
                    .font(.system(size: size))
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        Text("사용자 역할 아이콘")
            .font(.headline)

        HStack(spacing: 20) {
            VStack {
                UserRoleIcon(role: .firstTimeMother, size: 50)
                Text("초산모")
                    .font(.caption)
            }

            VStack {
                UserRoleIcon(role: .experiencedMother, size: 50)
                Text("경산모")
                    .font(.caption)
            }

            VStack {
                UserRoleIcon(role: .father, size: 50)
                Text("아빠")
                    .font(.caption)
            }
        }

        Divider()

        Text("배경 없이")
            .font(.headline)

        HStack(spacing: 20) {
            UserRoleIcon(role: .firstTimeMother, size: 40, showBackground: false)
            UserRoleIcon(role: .experiencedMother, size: 40, showBackground: false)
            UserRoleIcon(role: .father, size: 40, showBackground: false)
        }
    }
    .padding()
}
