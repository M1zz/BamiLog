//
//  ContractionHistoryView.swift
//  BamiLog
//
//  Created by Leeo on 11/16/25.
//


import SwiftUI

struct ContractionHistoryView: View {
    @EnvironmentObject var contractionManager: ContractionManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // 배경 - 다크/라이트 모드 대응
                AppColors.background
                    .ignoresSafeArea()

                if contractionManager.contractions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.textSecondary.opacity(0.5))

                        Text("기록된 진통이 없습니다")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.textSecondary)
                    }
                } else {
                    List {
                        // 요약 섹션
                        Section {
                            VStack(spacing: 12) {
                                HStack(spacing: 16) {
                                    SummaryItem(
                                        title: "총 진통 횟수",
                                        value: "\(contractionManager.contractions.count)",
                                        unit: "회"
                                    )

                                    Divider()

                                    if let avgInterval = contractionManager.averageInterval {
                                        SummaryItem(
                                            title: "평균 간격",
                                            value: String(format: "%.1f", avgInterval),
                                            unit: "분"
                                        )
                                    }
                                }
                                .padding(.vertical, 6)

                                // 현재 단계
                                HStack {
                                    Text("현재 단계:")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppColors.textSecondary)
                                    Text(contractionManager.currentStage.title)
                                        .font(.system(size: 13))
                                        .fontWeight(.bold)
                                        .foregroundColor(contractionManager.currentStage.color)
                                }
                            }
                            .listRowBackground(AppColors.cardBackground)
                        }

                        // 진통 목록
                        Section(header: Text("진통 기록").foregroundColor(AppColors.textSecondary)) {
                            ForEach(Array(contractionManager.contractions.enumerated()), id: \.element.id) { index, contraction in
                                ContractionDetailRow(
                                    contraction: contraction,
                                    previousContraction: index < contractionManager.contractions.count - 1 ? contractionManager.contractions[index + 1] : nil,
                                    index: index + 1
                                )
                                .listRowBackground(AppColors.secondaryBackground)
                            }
                            .onDelete { indexSet in
                                contractionManager.deleteContraction(at: indexSet)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("전체 히스토리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
    }
}

struct SummaryItem: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ContractionDetailRow: View {
    let contraction: Contraction
    let previousContraction: Contraction?
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 주기, 길이, 통증 나란히
            HStack(spacing: 12) {
                // 1. 진통 간격
                if let previous = previousContraction {
                    let interval = contraction.timestamp.timeIntervalSince(previous.timestamp)
                    HStack(spacing: 4) {
                        Text("주기")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.cyan.opacity(0.7))
                        Text(formatInterval(interval))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.cyan)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                        Text("첫 진통")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.yellow)
                }

                // 2. 지속 시간
                if let duration = contraction.duration {
                    HStack(spacing: 3) {
                        Text("길이")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.orange.opacity(0.6))
                        Text(String(format: "%.0f초", duration))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.orange.opacity(0.9))
                    }
                }

                // 3. 통증 수치
                if let painLevel = contraction.painLevel {
                    HStack(spacing: 3) {
                        Text("통증")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.red.opacity(0.6))
                        Text("\(painLevel)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.red.opacity(0.9))
                    }
                }

                Spacer()
            }

            // 4. 시간 (오른쪽 아래)
            HStack {
                Spacer()
                Text(formattedDateTime(contraction.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(.vertical, 8)
    }

    func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 HH:mm:ss"
        return formatter.string(from: date)
    }

    func formatInterval(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        if minutes > 0 {
            return String(format: "%d분 %02d초", minutes, seconds)
        } else {
            return String(format: "%d초", seconds)
        }
    }
}

#Preview {
    ContractionHistoryView()
        .environmentObject(ContractionManager())
}
