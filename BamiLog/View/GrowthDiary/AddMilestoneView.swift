//
//  AddMilestoneView.swift
//  BamiLog
//
//  Created by Claude on 11/17/24.
//

import SwiftUI

struct AddMilestoneView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: MilestoneCategory = .physical
    @State private var date = Date()
    @State private var title: String = ""
    @State private var description: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        AppColors.warning.opacity(0.1),
                        AppColors.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // 헤더
                        VStack(spacing: AppSpacing.xs) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 50))
                                .foregroundColor(AppColors.warning)

                            Text("발달 이정표 추가")
                                .font(AppTypography.title2)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(.top, AppSpacing.lg)

                        // 카테고리 선택
                        MilestoneCategorySelector(selectedCategory: $selectedCategory)

                        // 날짜
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Label("달성 날짜", systemImage: "calendar")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppRadius.md)

                        // 제목
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Label("이정표 제목", systemImage: "text.cursor")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            TextField("예: 첫 걸음", text: $title)
                                .font(AppTypography.body)
                                .padding(AppSpacing.md)
                                .background(Color.white)
                                .cornerRadius(AppRadius.sm)
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppRadius.md)

                        // 설명
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Label("설명", systemImage: "doc.text")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            TextEditor(text: $description)
                                .frame(height: 150)
                                .padding(AppSpacing.sm)
                                .background(Color.white)
                                .cornerRadius(AppRadius.sm)
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppRadius.md)

                        // 저장 버튼
                        AppButton(
                            "저장",
                            icon: "checkmark.circle.fill",
                            color: AppColors.warning,
                            fullWidth: true
                        ) {
                            saveMilestone()
                        }
                        .disabled(title.isEmpty)

                        Spacer(minLength: AppSpacing.lg)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveMilestone() {
        // TODO: 실제 저장 로직
        dismiss()
    }
}

struct MilestoneCategorySelector: View {
    @Binding var selectedCategory: MilestoneCategory

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("카테고리")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(MilestoneCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 14))

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
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.md)
    }
}

struct AddMilestoneView_Previews: PreviewProvider {
    static var previews: some View {
        AddMilestoneView()
    }
}
