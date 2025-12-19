//
//  DashboardView.swift
//  BamiLog
//
//  Created by Claude on 11/17/24.
//

import SwiftUI

struct DashboardView: View {
    @State private var babyProfile: BabyInfomation?
    @State private var recentGrowth: GrowthRecord?
    @State private var milestoneCount: Int = 0
    @State private var teethCount: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // 아기 프로필 카드
                BabyProfileCard(profile: babyProfile)

                // 빠른 통계
                QuickStatsGrid(
                    milestoneCount: milestoneCount,
                    teethCount: teethCount,
                    recentGrowth: recentGrowth
                )

                // 최근 활동
                RecentActivitySection()

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
        }
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        // 프로필 로드
        PersitenceManager.retrieveProfile(key: .profile) { result in
            if case .success(let profile) = result {
                babyProfile = profile
            }
        }

        // 통계 로드 (추후 구현)
        milestoneCount = 5
        teethCount = 2
    }
}

// MARK: - Baby Profile Card
struct BabyProfileCard: View {
    let profile: BabyInfomation?

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.phase2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile?.name ?? "아기")
                        .font(AppTypography.title2)
                        .foregroundColor(AppColors.textPrimary)

                    if let birthDate = profile?.birthDate {
                        Text(ageString(from: birthDate))
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()
            }

            Divider()

            HStack(spacing: AppSpacing.lg) {
                if let birthDate = profile?.birthDate {
                    InfoColumn(
                        title: "생일",
                        value: birthDate.formatted("yyyy.MM.dd"),
                        icon: "calendar"
                    )
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private func ageString(from birthDate: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate, to: now)

        if let years = components.year, years > 0 {
            return "\(years)살"
        } else if let months = components.month, months > 0 {
            return "\(months)개월"
        } else if let days = components.day {
            return "\(days)일"
        }
        return "오늘 태어남"
    }
}

struct InfoColumn: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)

            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)

            Text(value)
                .font(AppTypography.body)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Quick Stats Grid
struct QuickStatsGrid: View {
    let milestoneCount: Int
    let teethCount: Int
    let recentGrowth: GrowthRecord?

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                StatCard(
                    title: "이정표",
                    value: "\(milestoneCount)",
                    icon: "star.fill",
                    color: AppColors.warning
                )

                StatCard(
                    title: "이빨",
                    value: "\(teethCount)",
                    icon: "mouth.fill",
                    color: AppColors.info
                )
            }

            HStack(spacing: AppSpacing.md) {
                if let growth = recentGrowth {
                    StatCard(
                        title: "키",
                        value: String(format: "%.1f cm", growth.heightCm ?? 0),
                        icon: "arrow.up",
                        color: AppColors.phase1
                    )

                    StatCard(
                        title: "몸무게",
                        value: String(format: "%.1f kg", growth.weightKg ?? 0),
                        icon: "scalemass.fill",
                        color: AppColors.phase2
                    )
                } else {
                    StatCard(
                        title: "키",
                        value: "-",
                        icon: "arrow.up",
                        color: AppColors.phase1
                    )

                    StatCard(
                        title: "몸무게",
                        value: "-",
                        icon: "scalemass.fill",
                        color: AppColors.phase2
                    )
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(AppTypography.title3)
                .foregroundColor(AppColors.textPrimary)

            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.md)
        .background(color.opacity(0.1))
        .cornerRadius(AppRadius.md)
    }
}

// MARK: - Recent Activity Section
struct RecentActivitySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("최근 활동")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: AppSpacing.sm) {
                ActivityRow(
                    icon: "book.fill",
                    title: "일기 작성됨",
                    subtitle: "오늘",
                    color: AppColors.phase2
                )

                ActivityRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "성장 기록 추가됨",
                    subtitle: "2일 전",
                    color: AppColors.phase1
                )
            }
        }
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(AppRadius.sm)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)

                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.md)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
