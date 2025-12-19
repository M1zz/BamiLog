//
//  MilestoneView.swift
//  BamiLog
//
//  Created by Claude on 11/17/24.
//

import SwiftUI

struct MilestoneView: View {
    @State private var milestones: [Milestone] = MilestoneCategory.defaultMilestones
    @State private var selectedCategory: MilestoneCategory? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // 카테고리 필터
                CategoryFilterBar(selectedCategory: $selectedCategory)

                // 이정표 목록
                ForEach(filteredMilestones) { milestone in
                    MilestoneCard(milestone: milestone)
                }

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
        }
    }

    private var filteredMilestones: [Milestone] {
        if let category = selectedCategory {
            return milestones.filter { $0.category == category }
        }
        return milestones
    }
}

struct CategoryFilterBar: View {
    @Binding var selectedCategory: MilestoneCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                // 전체 버튼
                Button(action: {
                    selectedCategory = nil
                }) {
                    Text("전체")
                        .font(AppTypography.caption)
                        .foregroundColor(selectedCategory == nil ? .white : AppColors.textPrimary)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(selectedCategory == nil ? AppColors.phase2 : AppColors.cardBackground)
                        .cornerRadius(AppRadius.md)
                }

                // 카테고리 버튼들
                ForEach(MilestoneCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: category.icon)
                                .font(.system(size: 12))

                            Text(category.rawValue)
                                .font(AppTypography.caption)
                        }
                        .foregroundColor(selectedCategory == category ? .white : AppColors.textPrimary)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(selectedCategory == category ? category.color : AppColors.cardBackground)
                        .cornerRadius(AppRadius.md)
                    }
                }
            }
        }
    }
}

struct MilestoneCard: View {
    let milestone: Milestone

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // 체크박스
            ZStack {
                Circle()
                    .fill(milestone.isAchieved ? milestone.category.color : AppColors.cardBackground)
                    .frame(width: 40, height: 40)

                if milestone.isAchieved {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: milestone.category.icon)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .strikethrough(milestone.isAchieved)

                Text(milestone.category.rawValue)
                    .font(AppTypography.caption)
                    .foregroundColor(milestone.category.color)

                if !milestone.description.isEmpty {
                    Text(milestone.description)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }

                if milestone.isAchieved {
                    Text(milestone.date.formatted("yyyy.MM.dd 달성"))
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.phase2)
                }
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(milestone.isAchieved ? milestone.category.color : Color.clear, lineWidth: 2)
        )
    }
}

struct MilestoneView_Previews: PreviewProvider {
    static var previews: some View {
        MilestoneView()
    }
}
