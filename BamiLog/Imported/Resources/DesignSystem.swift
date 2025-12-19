//
//  DesignSystem.swift
//  BamiLog
//
//  Created by Claude on 11/15/24.
//

import SwiftUI

// MARK: - 통일된 컬러 시스템 (다크모드 대응)
struct AppColors {
    // Primary Colors - 밝고 선명한 색상
    static let primary = Color(red: 0.2, green: 0.5, blue: 0.8)        // 진한 하늘색
    static let secondary = Color(red: 0.85, green: 0.4, blue: 0.6)     // 진한 분홍
    static let accent = Color(red: 0.2, green: 0.7, blue: 0.6)         // 진한 민트

    // Background Colors - 다크모드 대응
    static let background = Color(.systemBackground)
    static let cardBackground = Color(.secondarySystemBackground)
    static let secondaryBackground = Color(.tertiarySystemBackground)

    // Text Colors - 다크모드 대응
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
    static let textLight = Color.white

    // Status Colors - 높은 대비
    static let success = Color(red: 0.2, green: 0.7, blue: 0.4)       // 선명한 초록
    static let warning = Color(red: 0.95, green: 0.6, blue: 0.1)      // 선명한 오렌지
    static let error = Color(red: 0.9, green: 0.2, blue: 0.3)         // 선명한 빨강
    static let info = Color(red: 0.2, green: 0.5, blue: 0.8)          // 선명한 파랑

    // Phase Specific Colors - 더 진한 색상
    static let phase1 = Color(red: 0.85, green: 0.4, blue: 0.6)   // 진한 분홍 - 진통
    static let phase2 = Color(red: 0.2, green: 0.5, blue: 0.8)    // 진한 하늘색 - 호흡
    static let phase3 = Color(red: 0.2, green: 0.7, blue: 0.6)    // 진한 민트 - 아기돌봄

    // Gradient Backgrounds - 다크모드 대응
    static let gradient1 = LinearGradient(
        colors: [
            Color(.systemBackground),
            Color(.systemBackground).opacity(0.8)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gradient2 = LinearGradient(
        colors: [
            Color(.systemBackground),
            Color(.systemBackground).opacity(0.9)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Typography
struct AppTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title1 = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 22, weight: .semibold)
    static let title3 = Font.system(size: 20, weight: .semibold)
    static let headline = Font.system(size: 17, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let callout = Font.system(size: 16, weight: .regular)
    static let subheadline = Font.system(size: 15, weight: .regular)
    static let footnote = Font.system(size: 13, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
}

// MARK: - Spacing
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct AppRadius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let round: CGFloat = 1000
}

// MARK: - Shadows
struct AppShadow {
    static let light = Shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    static let medium = Shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    static let heavy = Shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - 재사용 가능한 컴포넌트
struct AppCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat

    init(
        padding: CGFloat = AppSpacing.md,
        cornerRadius: CGFloat = AppRadius.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        content
            .padding(padding)
            .background(AppColors.cardBackground)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

struct AppButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void
    let fullWidth: Bool

    init(
        _ title: String,
        icon: String? = nil,
        color: Color = AppColors.primary,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
        self.fullWidth = fullWidth
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .font(AppTypography.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(color)
            .cornerRadius(AppRadius.md)
            .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
        }
    }
}

struct AppIconButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    init(
        icon: String,
        label: String,
        color: Color = AppColors.primary,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.label = label
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(color.opacity(0.4), lineWidth: 2)
                        )

                    Image(systemName: icon)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(color)
                }

                Text(label)
                    .font(AppTypography.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    let action: (() -> Void)?
    let actionLabel: String?

    init(_ title: String, action: (() -> Void)? = nil, actionLabel: String? = nil) {
        self.title = title
        self.action = action
        self.actionLabel = actionLabel
    }

    var body: some View {
        HStack {
            Text(title)
                .font(AppTypography.title3)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            if let action = action, let actionLabel = actionLabel {
                Button(action: action) {
                    Text(actionLabel)
                        .font(AppTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                }
            }
        }
    }
}

struct SectionHeaderWithSettings: View {
    let title: String
    let settingsAction: () -> Void
    let resetAction: (() -> Void)?
    let stopTimerAction: (() -> Void)?

    init(_ title: String, settingsAction: @escaping () -> Void, resetAction: (() -> Void)? = nil, stopTimerAction: (() -> Void)? = nil) {
        self.title = title
        self.settingsAction = settingsAction
        self.resetAction = resetAction
        self.stopTimerAction = stopTimerAction
    }

    var body: some View {
        HStack {
            Text(title)
                .font(AppTypography.title3)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            HStack(spacing: 16) {
                // 타이머 중지 버튼 (옵션)
                if let stopTimerAction = stopTimerAction {
                    Button(action: stopTimerAction) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.orange)
                    }
                }

                // 초기화 버튼 (옵션)
                if let resetAction = resetAction {
                    Button(action: resetAction) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.error)
                    }
                }

                // 설정 버튼
                Button(action: settingsAction) {
                    Image(systemName: "gear")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.background)
    }
}

// MARK: - View Extensions
extension View {
    func appCardStyle() -> some View {
        self
            .padding(AppSpacing.md)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }

    func appSecondaryCardStyle() -> some View {
        self
            .padding(AppSpacing.md)
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(Color(.separator).opacity(0.2), lineWidth: 1)
            )
    }
}
