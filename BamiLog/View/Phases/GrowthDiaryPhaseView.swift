//
//  GrowthDiaryPhaseView.swift
//  BamiLog
//
//  Created by Claude on 11/17/24.
//

import SwiftUI

struct GrowthDiaryPhaseView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: GrowthTab = .dashboard
    @State private var showAddMenu = false

    var body: some View {
        NavigationStack {
            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    colors: [
                        AppColors.phase2.opacity(0.1),
                        AppColors.phase2.opacity(0.05),
                        AppColors.background
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 탭별 컨텐츠
                    TabView(selection: $selectedTab) {
                        DashboardView()
                            .tag(GrowthTab.dashboard)

                        GrowthChartView()
                            .tag(GrowthTab.growth)

                        DiaryListView()
                            .tag(GrowthTab.diary)

                        MilestoneView()
                            .tag(GrowthTab.milestones)

                        ToothTrackerView()
                            .tag(GrowthTab.teeth)

                        PhotoGalleryView()
                            .tag(GrowthTab.photos)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    // 커스텀 탭 바
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        appState.showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(selectedTab.title)
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Phase 4")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddMenu = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.phase2)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddMenu) {
            AddMenuSheet(selectedTab: $selectedTab)
        }
    }
}

// MARK: - Growth Tab Enum
enum GrowthTab: String, CaseIterable {
    case dashboard = "대시보드"
    case growth = "성장"
    case diary = "일기"
    case milestones = "이정표"
    case teeth = "이빨"
    case photos = "사진"

    var title: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .growth: return "chart.line.uptrend.xyaxis"
        case .diary: return "book.fill"
        case .milestones: return "star.fill"
        case .teeth: return "mouth.fill"
        case .photos: return "photo.fill"
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: GrowthTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(GrowthTab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }
                )
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColors.cardBackground)
        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
    }
}

struct TabBarButton: View {
    let tab: GrowthTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: isSelected ? 20 : 18))
                    .foregroundColor(isSelected ? AppColors.phase2 : AppColors.textSecondary)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColors.phase2 : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill(isSelected ? AppColors.phase2.opacity(0.1) : Color.clear)
            )
        }
    }
}

// MARK: - Add Menu Sheet
struct AddMenuSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: GrowthTab
    @State private var showGrowthRecordSheet = false
    @State private var showDiarySheet = false
    @State private var showMilestoneSheet = false
    @State private var showToothSheet = false

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

                VStack(spacing: AppSpacing.lg) {
                    // 헤더
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.phase2)

                        Text("새로 추가하기")
                            .font(AppTypography.title2)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.top, AppSpacing.xl)

                    // 메뉴 버튼들
                    VStack(spacing: AppSpacing.md) {
                        AddMenuButton(
                            title: "성장 기록",
                            subtitle: "키, 몸무게 측정 결과",
                            icon: "chart.line.uptrend.xyaxis",
                            color: AppColors.phase1
                        ) {
                            showGrowthRecordSheet = true
                        }

                        AddMenuButton(
                            title: "일기 작성",
                            subtitle: "오늘의 특별한 순간",
                            icon: "book.fill",
                            color: AppColors.phase2
                        ) {
                            showDiarySheet = true
                        }

                        AddMenuButton(
                            title: "발달 이정표",
                            subtitle: "새로운 이정표 달성",
                            icon: "star.fill",
                            color: AppColors.warning
                        ) {
                            showMilestoneSheet = true
                        }

                        AddMenuButton(
                            title: "이빨 기록",
                            subtitle: "새로 난 이빨 추가",
                            icon: "mouth.fill",
                            color: AppColors.info
                        ) {
                            showToothSheet = true
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    Spacer()
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
        .sheet(isPresented: $showGrowthRecordSheet) {
            AddGrowthRecordView()
        }
        .sheet(isPresented: $showDiarySheet) {
            AddDiaryView()
        }
        .sheet(isPresented: $showMilestoneSheet) {
            AddMilestoneView()
        }
        .sheet(isPresented: $showToothSheet) {
            AddToothRecordView()
        }
    }
}

struct AddMenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(AppSpacing.md)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.md)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
    }
}

// MARK: - Preview
struct GrowthDiaryPhaseView_Previews: PreviewProvider {
    static var previews: some View {
        GrowthDiaryPhaseView()
            .environmentObject(AppState())
    }
}
