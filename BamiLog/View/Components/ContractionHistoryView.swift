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
                // 배경 - 회색
                Color(red: 0.95, green: 0.95, blue: 0.95)
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
                            .listRowBackground(Color.white)
                        }

                        // 진통 목록
                        Section(header: Text("진통 기록").foregroundColor(AppColors.textSecondary)) {
                            ForEach(Array(contractionManager.contractions.enumerated()), id: \.element.id) { index, contraction in
                                ContractionDetailRow(
                                    contraction: contraction,
                                    previousContraction: index < contractionManager.contractions.count - 1 ? contractionManager.contractions[index + 1] : nil,
                                    index: index + 1
                                )
                                .listRowBackground(Color.white)
                            }
                            .onDelete { indexSet in
                                contractionManager.deleteContraction(at: indexSet)
                            }
                        }

                        // 통증 수준 그래프
                        Section(header: Text("통증 수준 변화").foregroundColor(AppColors.textSecondary)) {
                            PainLevelChart(contractions: contractionManager.contractions)
                                .listRowBackground(Color.white)
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

// 통증 수준 그래프
struct PainLevelChart: View {
    let contractions: [Contraction]

    var painData: [(index: Int, level: Int)] {
        let contractionsWithPain = contractions.reversed().enumerated().compactMap { (index, contraction) -> (index: Int, level: Int)? in
            if let painLevel = contraction.painLevel, painLevel > 0 {
                return (index + 1, painLevel)
            }
            return nil
        }
        return Array(contractionsWithPain.prefix(10)) // 최근 10개만 표시
    }

    var maxPainLevel: Int {
        painData.map { $0.level }.max() ?? 10
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if painData.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("통증 수준 데이터가 없습니다")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                // 그래프 제목과 범례
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("통증 수준 추이")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        Text("최근 \(painData.count)회 기록")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // 평균 통증 수준
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("평균")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)

                        Text("\(String(format: "%.1f", Double(painData.map { $0.level }.reduce(0, +)) / Double(painData.count)))")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.red)
                    }
                }

                // 막대 그래프
                GeometryReader { geometry in
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(painData, id: \.index) { data in
                            VStack(spacing: 4) {
                                // 통증 수준 숫자
                                Text("\(data.level)")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.red)

                                // 막대
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [painColor(for: data.level), painColor(for: data.level).opacity(0.7)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: CGFloat(data.level) / CGFloat(maxPainLevel) * 120)
                                    .cornerRadius(4)

                                // 진통 번호
                                Text("#\(data.index)")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(height: 160)
                .padding(.vertical, 8)

                // 통증 수준 설명
                VStack(alignment: .leading, spacing: 6) {
                    Text("통증 수준 안내")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        painLevelIndicator(range: "1-3", color: .orange, label: "낮음")
                        painLevelIndicator(range: "4-6", color: Color(red: 1.0, green: 0.3, blue: 0.3), label: "보통")
                        painLevelIndicator(range: "7-10", color: .red, label: "높음")
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
    }

    func painColor(for level: Int) -> Color {
        if level <= 3 {
            return .orange
        } else if level <= 6 {
            return Color(red: 1.0, green: 0.3, blue: 0.3)
        } else {
            return .red
        }
    }

    func painLevelIndicator(range: String, color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text("\(range): \(label)")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContractionHistoryView()
        .environmentObject(ContractionManager())
}
