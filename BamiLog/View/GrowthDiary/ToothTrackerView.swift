//
//  ToothTrackerView.swift
//  BamiLog
//
//  Created by Claude on 11/17/24.
//

import SwiftUI

struct ToothTrackerView: View {
    @State private var toothRecords: [ToothRecord] = []

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // 통계
                ToothStatsCard(totalTeeth: toothRecords.count)

                // 치아 다이어그램
                ToothDiagram(records: toothRecords)

                // 기록 목록
                ToothRecordList(records: toothRecords)

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
        }
        .onAppear {
            loadToothRecords()
        }
    }

    private func loadToothRecords() {
        // TODO: 실제 데이터 로드
        toothRecords = []
    }
}

struct ToothStatsCard: View {
    let totalTeeth: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("총 이빨 개수")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xs) {
                    Text("\(totalTeeth)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppColors.info)

                    Text("개")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "mouth.fill")
                .font(.system(size: 50))
                .foregroundColor(AppColors.info.opacity(0.3))
        }
        .padding(AppSpacing.lg)
        .background(AppColors.info.opacity(0.1))
        .cornerRadius(AppRadius.lg)
    }
}

struct ToothDiagram: View {
    let records: [ToothRecord]

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("치아 배치도")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: AppSpacing.md) {
                // 윗니
                VStack(spacing: AppSpacing.xs) {
                    Text("윗니")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    HStack(spacing: 4) {
                        ForEach(0..<10) { index in
                            ToothIcon(isErupted: false)
                        }
                    }
                }

                Divider()

                // 아랫니
                VStack(spacing: AppSpacing.xs) {
                    HStack(spacing: 4) {
                        ForEach(0..<10) { index in
                            ToothIcon(isErupted: false)
                        }
                    }

                    Text("아랫니")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(AppSpacing.lg)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.lg)
        }
    }
}

struct ToothIcon: View {
    let isErupted: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(isErupted ? AppColors.info : AppColors.textSecondary.opacity(0.2))
            .frame(width: 20, height: 30)
    }
}

struct ToothRecordList: View {
    let records: [ToothRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("이빨 기록")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            if records.isEmpty {
                EmptyToothState()
            } else {
                ForEach(records) { record in
                    ToothRecordRow(record: record)
                }
            }
        }
    }
}

struct EmptyToothState: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "mouth.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textSecondary)

            Text("이빨 기록이 없습니다")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("+ 버튼을 눌러 첫 이빨을 기록하세요")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
    }
}

struct ToothRecordRow: View {
    let record: ToothRecord

    var body: some View {
        HStack {
            Image(systemName: "mouth.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColors.info)
                .frame(width: 40, height: 40)
                .background(AppColors.info.opacity(0.1))
                .cornerRadius(AppRadius.sm)

            VStack(alignment: .leading, spacing: 4) {
                Text(record.toothPosition.simpleName)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)

                if let date = record.dateErupted {
                    Text(date.formatted("yyyy.MM.dd 발치"))
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.md)
    }
}

struct ToothTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        ToothTrackerView()
    }
}
