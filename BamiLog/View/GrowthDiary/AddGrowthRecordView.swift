//
//  AddGrowthRecordView.swift
//  BamiLog
//
//  Created by Claude on 11/17/24.
//

import SwiftUI

struct AddGrowthRecordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var date = Date()
    @State private var heightCm: String = ""
    @State private var weightKg: String = ""
    @State private var headCircumferenceCm: String = ""
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        AppColors.phase1.opacity(0.1),
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
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 50))
                                .foregroundColor(AppColors.phase1)

                            Text("성장 기록 추가")
                                .font(AppTypography.title2)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(.top, AppSpacing.lg)

                        // 날짜
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Label("측정 날짜", systemImage: "calendar")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppRadius.md)

                        // 키
                        InputField(
                            title: "키 (cm)",
                            icon: "arrow.up",
                            placeholder: "예: 75.5",
                            text: $heightCm,
                            keyboardType: .decimalPad
                        )

                        // 몸무게
                        InputField(
                            title: "몸무게 (kg)",
                            icon: "scalemass.fill",
                            placeholder: "예: 9.5",
                            text: $weightKg,
                            keyboardType: .decimalPad
                        )

                        // 머리 둘레 (선택)
                        InputField(
                            title: "머리 둘레 (cm) - 선택사항",
                            icon: "circle",
                            placeholder: "예: 45.0",
                            text: $headCircumferenceCm,
                            keyboardType: .decimalPad
                        )

                        // 메모
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Label("메모", systemImage: "note.text")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            TextEditor(text: $note)
                                .frame(height: 100)
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
                            color: AppColors.phase1,
                            fullWidth: true
                        ) {
                            saveRecord()
                        }
                        .disabled(heightCm.isEmpty && weightKg.isEmpty)

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

    private func saveRecord() {
        // TODO: 실제 저장 로직
        dismiss()
    }
}

struct InputField: View {
    let title: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Label(title, systemImage: icon)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .font(AppTypography.body)
                .padding(AppSpacing.md)
                .background(Color.white)
                .cornerRadius(AppRadius.sm)
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.md)
    }
}

struct AddGrowthRecordView_Previews: PreviewProvider {
    static var previews: some View {
        AddGrowthRecordView()
    }
}
