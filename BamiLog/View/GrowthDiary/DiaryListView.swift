//
//  DiaryListView.swift
//  BamiLog
//
//  Created by Claude on 11/17/24.
//

import SwiftUI

struct DiaryListView: View {
    @State private var diaryEntries: [DiaryEntry] = []
    @State private var selectedFilter: DiaryFilter = .all

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // 필터
                DiaryFilterBar(selectedFilter: $selectedFilter)

                // 일기 목록
                if filteredEntries.isEmpty {
                    EmptyDiaryState()
                } else {
                    ForEach(filteredEntries) { entry in
                        DiaryCard(entry: entry)
                    }
                }

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
        }
        .onAppear {
            loadDiaries()
        }
    }

    private var filteredEntries: [DiaryEntry] {
        switch selectedFilter {
        case .all:
            return diaryEntries
        case .free:
            return diaryEntries.filter { $0.type == .free }
        case .template:
            return diaryEntries.filter { $0.type != .free }
        }
    }

    private func loadDiaries() {
        // TODO: 실제 데이터 로드
        diaryEntries = []
    }
}

enum DiaryFilter: String, CaseIterable {
    case all = "전체"
    case free = "자유 일기"
    case template = "템플릿"
}

struct DiaryFilterBar: View {
    @Binding var selectedFilter: DiaryFilter

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(DiaryFilter.allCases, id: \.self) { filter in
                Button(action: {
                    selectedFilter = filter
                }) {
                    Text(filter.rawValue)
                        .font(AppTypography.body)
                        .foregroundColor(selectedFilter == filter ? .white : AppColors.textPrimary)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(selectedFilter == filter ? AppColors.phase2 : AppColors.cardBackground)
                        .cornerRadius(AppRadius.md)
                }
            }
        }
    }
}

struct EmptyDiaryState: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textSecondary)

            Text("작성된 일기가 없습니다")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("+ 버튼을 눌러 첫 일기를 작성하세요")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
    }
}

struct DiaryCard: View {
    let entry: DiaryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // 헤더
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text(entry.date.formatted("yyyy.MM.dd"))
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                if let mood = entry.mood {
                    Text(mood.rawValue)
                        .font(.system(size: 24))
                }
            }

            // 내용 미리보기
            Text(entry.content)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(3)

            // 사진 미리보기
            if !entry.photos.isEmpty {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.info)

                    Text("\(entry.photos.count)장의 사진")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.info)
                }
            }

            // 타입 뱃지
            Text(entry.type.rawValue)
                .font(.system(size: 10))
                .foregroundColor(.white)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, 4)
                .background(AppColors.phase2)
                .cornerRadius(AppRadius.sm)
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

struct DiaryListView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryListView()
    }
}
