//
//  AddToothRecordView.swift
//  BamiLog
//
//  Created by Claude on 11/17/24.
//

import SwiftUI

struct AddToothRecordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPosition: ToothPosition = .lowerCentralIncisor1
    @State private var dateErupted = Date()
    @State private var note: String = ""
    @State private var showingPositionPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        AppColors.info.opacity(0.1),
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
                            Image(systemName: "mouth.fill")
                                .font(.system(size: 50))
                                .foregroundColor(AppColors.info)

                            Text("이빨 기록 추가")
                                .font(AppTypography.title2)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(.top, AppSpacing.lg)

                        // 이빨 위치 선택
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Label("이빨 위치", systemImage: "location")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            Button(action: {
                                showingPositionPicker = true
                            }) {
                                HStack {
                                    Text(selectedPosition.simpleName)
                                        .font(AppTypography.body)
                                        .foregroundColor(AppColors.textPrimary)

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding(AppSpacing.md)
                                .background(Color.white)
                                .cornerRadius(AppRadius.sm)
                            }
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppRadius.md)

                        // 발치 날짜
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Label("발치 날짜", systemImage: "calendar")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)

                            DatePicker("", selection: $dateErupted, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppRadius.md)

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
                            color: AppColors.info,
                            fullWidth: true
                        ) {
                            saveToothRecord()
                        }

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
        .sheet(isPresented: $showingPositionPicker) {
            ToothPositionPicker(selectedPosition: $selectedPosition)
        }
    }

    private func saveToothRecord() {
        // TODO: 실제 저장 로직
        dismiss()
    }
}

struct ToothPositionPicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedPosition: ToothPosition

    var body: some View {
        NavigationStack {
            List {
                Section("윗니") {
                    ForEach(ToothPosition.allCases.filter { $0.isUpper }, id: \.self) { position in
                        Button(action: {
                            selectedPosition = position
                            dismiss()
                        }) {
                            HStack {
                                Text(position.simpleName)
                                    .foregroundColor(AppColors.textPrimary)

                                Spacer()

                                if selectedPosition == position {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppColors.info)
                                }
                            }
                        }
                    }
                }

                Section("아랫니") {
                    ForEach(ToothPosition.allCases.filter { !$0.isUpper }, id: \.self) { position in
                        Button(action: {
                            selectedPosition = position
                            dismiss()
                        }) {
                            HStack {
                                Text(position.simpleName)
                                    .foregroundColor(AppColors.textPrimary)

                                Spacer()

                                if selectedPosition == position {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppColors.info)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("이빨 위치 선택")
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
}

struct AddToothRecordView_Previews: PreviewProvider {
    static var previews: some View {
        AddToothRecordView()
    }
}
