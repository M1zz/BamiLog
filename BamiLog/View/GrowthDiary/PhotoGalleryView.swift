//
//  PhotoGalleryView.swift
//  BamiLog
//
//  Created by Claude on 11/17/24.
//

import SwiftUI

struct PhotoGalleryView: View {
    @State private var photos: [GalleryPhoto] = []
    @State private var selectedFilter: PhotoFilter = .all

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // 필터
                PhotoFilterBar(selectedFilter: $selectedFilter)

                // 사진 그리드
                if filteredPhotos.isEmpty {
                    EmptyPhotoState()
                } else {
                    PhotoGrid(photos: filteredPhotos)
                }

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
        }
        .onAppear {
            loadPhotos()
        }
    }

    private var filteredPhotos: [GalleryPhoto] {
        switch selectedFilter {
        case .all:
            return photos
        case .thisMonth:
            let calendar = Calendar.current
            let now = Date()
            return photos.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        case .thisYear:
            let calendar = Calendar.current
            let now = Date()
            return photos.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .year) }
        }
    }

    private func loadPhotos() {
        // TODO: 실제 데이터 로드
        photos = []
    }
}

enum PhotoFilter: String, CaseIterable {
    case all = "전체"
    case thisMonth = "이번 달"
    case thisYear = "올해"
}

struct GalleryPhoto: Identifiable {
    let id = UUID()
    let date: Date
    let imageName: String
    let source: PhotoSource
}

enum PhotoSource {
    case diary
    case milestone
    case standalone
}

struct PhotoFilterBar: View {
    @Binding var selectedFilter: PhotoFilter

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(PhotoFilter.allCases, id: \.self) { filter in
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

struct EmptyPhotoState: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "photo.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textSecondary)

            Text("사진이 없습니다")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("일기나 이정표에 사진을 추가하세요")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
    }
}

struct PhotoGrid: View {
    let photos: [GalleryPhoto]

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.xs),
        GridItem(.flexible(), spacing: AppSpacing.xs),
        GridItem(.flexible(), spacing: AppSpacing.xs)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.xs) {
            ForEach(photos) { photo in
                PhotoGridItem(photo: photo)
            }
        }
    }
}

struct PhotoGridItem: View {
    let photo: GalleryPhoto

    var body: some View {
        RoundedRectangle(cornerRadius: AppRadius.sm)
            .fill(AppColors.cardBackground)
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(AppColors.textSecondary)
            )
    }
}

struct PhotoGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoGalleryView()
    }
}
