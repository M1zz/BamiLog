//
//  SettingsView.swift
//  laborBreath
//
//  Created by Claude on 11/14/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var contractionManager: ContractionManager

    @State private var showDeleteAlert = false
    @State private var showLogView = false

    var body: some View {
        NavigationView {
            ZStack {
                // 배경 그라데이션
                AppColors.gradient1
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 페이즈 선택 섹션
                        VStack(alignment: .leading, spacing: 12) {
                            Text("현재 단계")
                                .font(AppTypography.title3)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal, 16)

                            Text("출산 과정의 단계를 선택하세요")
                                .font(AppTypography.footnote)
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.horizontal, 16)

                            VStack(spacing: 12) {
                                ForEach(AppPhase.allCases) { phase in
                                    PhaseSelectionCard(
                                        phase: phase,
                                        isSelected: appState.currentPhase == phase,
                                        action: {
                                            appState.currentPhase = phase
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 20)

                        // 데이터 관리 섹션
                        VStack(alignment: .leading, spacing: 12) {
                            Text("데이터 관리")
                                .font(AppTypography.title3)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal, 16)

                            VStack(spacing: 12) {
                                // 로그 보기 버튼
                                Button(action: {
                                    showLogView = true
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "doc.text.magnifyingglass")
                                            .font(.system(size: 20))
                                            .foregroundColor(.cyan)
                                            .frame(width: 40)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("로그 보기")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)

                                            Text("진통 기록과 상세 정보를 확인합니다")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.6))
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.4))
                                    }
                                    .padding(16)
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(14)
                                }

                                // 진통 기록 초기화 버튼
                                Button(action: {
                                    showDeleteAlert = true
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.red)
                                            .frame(width: 40)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("진통 기록 초기화")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)

                                            Text("모든 진통 기록을 삭제합니다")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.6))
                                        }

                                        Spacer()
                                    }
                                    .padding(16)
                                    .background(Color.red.opacity(0.15))
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
            .sheet(isPresented: $showLogView) {
                LogView()
                    .environmentObject(contractionManager)
                    .environmentObject(appState)
            }
            .alert("진통 기록 삭제", isPresented: $showDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    contractionManager.deleteAllContractions()
                }
            } message: {
                Text("모든 기록을 삭제할까요?\n되돌릴 수 없습니다.")
            }
        }
    }
}

struct PhaseSelectionCard: View {
    let phase: AppPhase
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 아이콘
                Image(systemName: phase.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .cyan : .white.opacity(0.6))
                    .frame(width: 40)

                // 텍스트
                VStack(alignment: .leading, spacing: 4) {
                    Text(phase.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)

                    Text(phase.description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // 선택 표시
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.cyan)
                }
            }
            .padding(16)
            .background(
                isSelected ? Color.cyan.opacity(0.2) : Color.white.opacity(0.08)
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(ContractionManager())
}
