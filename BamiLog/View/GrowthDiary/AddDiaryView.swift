//
//  AddDiaryView.swift
//  BamiLog
//
//  Created by Claude on 11/17/24.
//

import SwiftUI

struct AddDiaryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedType: DiaryType = .free
    @State private var date = Date()
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedMood: Mood? = nil

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
                    VStack(spacing: AppSpacing.lg) {
                        // 헤더
                        VStack(spacing: AppSpacing.xs) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 50))
                                .foregroundColor(AppColors.phase2)

                            Text("일기 작성")
                                .font(AppTypography.title2)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(.top, AppSpacing.lg)

                        // 일기 타입 선택
                        DiaryTypeSelector(selectedType: $selectedType)

                        // 날짜
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Label("날짜", systemImage: "calendar")
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
                            Label("제목", systemImage: "text.cursor")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            TextField("제목을 입력하세요", text: $title)
                                .font(AppTypography.body)
                                .padding(AppSpacing.md)
                                .background(Color.white)
                                .cornerRadius(AppRadius.sm)
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppRadius.md)

                        // 기분 선택
                        MoodSelector(selectedMood: $selectedMood)

                        // 내용
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Label("내용", systemImage: "doc.text")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            TextEditor(text: $content)
                                .frame(height: 200)
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
                            color: AppColors.phase2,
                            fullWidth: true
                        ) {
                            saveDiary()
                        }
                        .disabled(title.isEmpty || content.isEmpty)

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

    private func saveDiary() {
        // TODO: 실제 저장 로직
        dismiss()
    }
}

struct DiaryTypeSelector: View {
    @Binding var selectedType: DiaryType

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("일기 형식")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach([DiaryType.free, .meal, .sleep, .activity], id: \.self) { type in
                        Button(action: {
                            selectedType = type
                        }) {
                            Text(type.rawValue)
                                .font(AppTypography.caption)
                                .foregroundColor(selectedType == type ? .white : AppColors.textPrimary)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(selectedType == type ? AppColors.phase2 : AppColors.cardBackground)
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

struct MoodSelector: View {
    @Binding var selectedMood: Mood?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Label("오늘의 기분", systemImage: "face.smiling")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)

            HStack(spacing: AppSpacing.md) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                    }) {
                        VStack(spacing: 4) {
                            Text(mood.rawValue)
                                .font(.system(size: 32))

                            if selectedMood == mood {
                                Circle()
                                    .fill(AppColors.phase2)
                                    .frame(width: 6, height: 6)
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 6, height: 6)
                            }
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

struct AddDiaryView_Previews: PreviewProvider {
    static var previews: some View {
        AddDiaryView()
    }
}
