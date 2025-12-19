//
//  GrowthChartView.swift
//  BamiLog
//
//  Created by Claude on 11/17/24.
//

import SwiftUI
import Charts

struct GrowthChartView: View {
    @State private var growthRecords: [GrowthRecord] = []
    @State private var selectedMetric: GrowthMetric = .height
    @State private var showAddSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // 메트릭 선택
                MetricSelector(selectedMetric: $selectedMetric)

                // 차트
                if growthRecords.isEmpty {
                    EmptyGrowthState()
                } else {
                    GrowthChart(records: growthRecords, metric: selectedMetric)
                }

                // 기록 목록
                GrowthRecordList(records: growthRecords)

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
        }
        .onAppear {
            loadRecords()
        }
    }

    private func loadRecords() {
        // TODO: 실제 데이터 로드
        growthRecords = []
    }
}

enum GrowthMetric: String, CaseIterable {
    case height = "키"
    case weight = "몸무게"
    case head = "머리둘레"
}

struct MetricSelector: View {
    @Binding var selectedMetric: GrowthMetric

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(GrowthMetric.allCases, id: \.self) { metric in
                Button(action: {
                    selectedMetric = metric
                }) {
                    Text(metric.rawValue)
                        .font(AppTypography.body)
                        .foregroundColor(selectedMetric == metric ? .white : AppColors.textPrimary)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(selectedMetric == metric ? AppColors.phase2 : AppColors.cardBackground)
                        .cornerRadius(AppRadius.md)
                }
            }
        }
    }
}

struct EmptyGrowthState: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textSecondary)

            Text("성장 기록이 없습니다")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("+ 버튼을 눌러 첫 기록을 추가하세요")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
    }
}

struct GrowthChart: View {
    let records: [GrowthRecord]
    let metric: GrowthMetric

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("\(metric.rawValue) 추이")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            // 간단한 차트 플레이스홀더
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(AppColors.cardBackground)
                .frame(height: 200)
                .overlay(
                    Text("차트 영역")
                        .foregroundColor(AppColors.textSecondary)
                )
        }
    }
}

struct GrowthRecordList: View {
    let records: [GrowthRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("기록")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            if records.isEmpty {
                Text("기록이 없습니다")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.lg)
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppRadius.md)
            } else {
                ForEach(records) { record in
                    GrowthRecordRow(record: record)
                }
            }
        }
    }
}

struct GrowthRecordRow: View {
    let record: GrowthRecord

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.date.formatted("yyyy.MM.dd"))
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)

                if let note = record.note, !note.isEmpty {
                    Text(note)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let height = record.heightCm {
                    Text("\(String(format: "%.1f", height)) cm")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                }

                if let weight = record.weightKg {
                    Text("\(String(format: "%.1f", weight)) kg")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.md)
    }
}

struct GrowthChartView_Previews: PreviewProvider {
    static var previews: some View {
        GrowthChartView()
    }
}
