//
//  PregnancyPhaseView.swift
//  BamiLog
//
//  Created by Claude on 12/16/25.
//

import SwiftUI

struct PregnancyPhaseView: View {
    @EnvironmentObject var pregnancyManager: PregnancyManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userProfileManager: UserProfileManager

    @State private var showSetupSheet = false
    @State private var showBabyNameSheet = false
    @State private var showCheckupSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.1),
                        AppColors.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if let pregnancy = pregnancyManager.pregnancyInfo {
                    ScrollView {
                        VStack(spacing: AppSpacing.lg) {
                            // 헤더: 태명 + D-Day
                            PregnancyHeaderCard(pregnancy: pregnancy, onEditName: {
                                showBabyNameSheet = true
                            })

                            // 중앙: 아기 이미지 + 주차 정보
                            BabyGrowthCard(pregnancy: pregnancy)

                            // 아기 발달 정보
                            FetalDevelopmentCard(week: pregnancy.currentWeek)

                            // 산모 건강 가이드
                            MotherGuideCard(week: pregnancy.currentWeek)

                            // 아빠 가이드
                            FatherGuideCard(week: pregnancy.currentWeek)

                            // 검진 일정
                            CheckupScheduleCard(onAddCheckup: {
                                showCheckupSheet = true
                            })

                            // 36주 이상: 진통 기록 버튼
                            if pregnancy.isLaborReady {
                                LaborReadyButton()
                            }

                            Spacer(minLength: AppSpacing.xl)
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.md)
                    }
                } else {
                    // 임신 정보 없을 때
                    PregnancySetupView(onSetup: {
                        showSetupSheet = true
                    })
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
                    Text("임신 정보")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            .sheet(isPresented: $showSetupSheet) {
                PregnancySetupSheet()
            }
            .sheet(isPresented: $showBabyNameSheet) {
                BabyNameEditSheet()
            }
            .sheet(isPresented: $showCheckupSheet) {
                CheckupAddSheet()
            }
        }
        .onAppear {
            pregnancyManager.updatePregnancyInfo()
        }
    }
}

// MARK: - 헤더 카드 (태명 + D-Day)

struct PregnancyHeaderCard: View {
    let pregnancy: PregnancyInfo
    let onEditName: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // 태명
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pregnancy.babyName ?? "아가")
                        .font(AppTypography.title1)
                        .foregroundColor(AppColors.textPrimary)

                    Text("\(pregnancy.currentWeek)주 \(pregnancy.currentDay)일")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Button(action: onEditName) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.purple)
                }
            }

            Divider()

            // D-Day
            HStack(spacing: AppSpacing.lg) {
                VStack(spacing: 4) {
                    Text("D-\(pregnancy.daysUntilDueDate)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.purple)

                    Text("출산까지")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Divider()
                    .frame(height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("예정일")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    Text(formatDate(pregnancy.expectedDueDate))
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                }

                Spacer()
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

// MARK: - 아기 성장 카드

struct BabyGrowthCard: View {
    @EnvironmentObject var pregnancyManager: PregnancyManager
    let pregnancy: PregnancyInfo

    var body: some View {
        let development = pregnancyManager.getFetalDevelopment(week: pregnancy.currentWeek)

        VStack(spacing: AppSpacing.md) {
            // 아기 이미지
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)

                Image(systemName: development.icon)
                    .font(.system(size: 80))
                    .foregroundColor(.purple)
            }

            // 크기 정보
            VStack(spacing: 4) {
                Text(development.fetalSize)
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.textPrimary)

                Text(development.fetalWeight)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
            }

            // 분기 표시
            HStack(spacing: AppSpacing.sm) {
                ForEach(1...3, id: \.self) { trimester in
                    Circle()
                        .fill(pregnancy.trimester >= trimester ? Color.purple : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }

                Text("\(pregnancy.trimester)분기")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - 태아 발달 정보 카드

struct FetalDevelopmentCard: View {
    @EnvironmentObject var pregnancyManager: PregnancyManager
    let week: Int

    var body: some View {
        let development = pregnancyManager.getFetalDevelopment(week: week)

        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .foregroundColor(.purple)
                Text("아기 발달")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }

            Text(development.title)
                .font(AppTypography.title3)
                .foregroundColor(AppColors.textPrimary)

            Text(development.description)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if !development.keyMilestones.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("주요 발달 사항")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textPrimary)

                    ForEach(development.keyMilestones, id: \.self) { milestone in
                        HStack(alignment: .top, spacing: AppSpacing.xs) {
                            Text("•")
                                .foregroundColor(.purple)
                            Text(milestone)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - 산모 건강 가이드 카드

struct MotherGuideCard: View {
    @EnvironmentObject var pregnancyManager: PregnancyManager
    let week: Int

    var body: some View {
        let guide = pregnancyManager.getMotherGuide(week: week)

        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.pink)
                Text("산모 건강 가이드")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }

            // 증상
            if !guide.commonSymptoms.isEmpty {
                InfoSection(
                    title: "흔한 증상",
                    items: guide.commonSymptoms,
                    icon: "circle.fill",
                    color: .orange
                )
            }

            // 팁
            if !guide.tips.isEmpty {
                InfoSection(
                    title: "건강 관리 팁",
                    items: guide.tips,
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }

            // 주의사항
            if !guide.warnings.isEmpty {
                InfoSection(
                    title: "주의사항",
                    items: guide.warnings,
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - 아빠 가이드 카드

struct FatherGuideCard: View {
    @EnvironmentObject var pregnancyManager: PregnancyManager
    @EnvironmentObject var userProfileManager: UserProfileManager
    let week: Int

    var body: some View {
        // 역할이 아빠일 때만 표시
        guard userProfileManager.profile?.userRole == .father else {
            return AnyView(EmptyView())
        }

        let guide = pregnancyManager.getFatherGuide(week: week)

        return AnyView(
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.blue)
                    Text(guide.title)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                }

                // 할 일
                if !guide.whatToDo.isEmpty {
                    InfoSection(
                        title: "해야 할 일",
                        items: guide.whatToDo,
                        icon: "checkmark.square.fill",
                        color: .blue
                    )
                }

                // 정서적 지원
                if !guide.emotionalSupport.isEmpty {
                    InfoSection(
                        title: "정서적 지원",
                        items: guide.emotionalSupport,
                        icon: "heart.fill",
                        color: .pink
                    )
                }

                // 실질적 도움
                if !guide.practicalHelp.isEmpty {
                    InfoSection(
                        title: "실질적 도움",
                        items: guide.practicalHelp,
                        icon: "wrench.and.screwdriver.fill",
                        color: .orange
                    )
                }
            }
            .padding(AppSpacing.lg)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.lg)
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
    }
}

// MARK: - 정보 섹션 (재사용 가능)

struct InfoSection: View {
    let title: String
    let items: [String]
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textPrimary)

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: AppSpacing.xs) {
                    Image(systemName: icon)
                        .font(.system(size: 8))
                        .foregroundColor(color)
                        .frame(width: 12, alignment: .center)
                        .offset(y: 4)

                    Text(item)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

// MARK: - 검진 일정 카드

struct CheckupScheduleCard: View {
    @EnvironmentObject var pregnancyManager: PregnancyManager
    let onAddCheckup: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.purple)
                Text("검진 일정")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button(action: onAddCheckup) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.purple)
                }
            }

            if pregnancyManager.upcomingCheckups.isEmpty {
                Text("다가오는 검진 일정이 없습니다")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, AppSpacing.md)
            } else {
                ForEach(pregnancyManager.upcomingCheckups.prefix(3)) { checkup in
                    CheckupRow(checkup: checkup)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

struct CheckupRow: View {
    @EnvironmentObject var pregnancyManager: PregnancyManager
    let checkup: CheckupSchedule

    var body: some View {
        HStack {
            Image(systemName: checkup.checkupType.icon)
                .foregroundColor(.purple)

            VStack(alignment: .leading, spacing: 2) {
                Text(checkup.title)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)

                Text(formatDate(checkup.scheduledDate))
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Button(action: {
                pregnancyManager.toggleCheckupCompletion(checkup)
            }) {
                Image(systemName: checkup.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(checkup.isCompleted ? .green : .gray)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

// MARK: - 진통 준비 버튼 (36주 이상)

struct LaborReadyButton: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: {
            appState.currentPhase = .laborAndBirth
        }) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text("진통 기록 시작")
                        .font(AppTypography.headline)
                        .foregroundColor(.white)

                    Text("36주 이상, 언제든 진통이 올 수 있습니다")
                        .font(AppTypography.caption)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
            .padding(AppSpacing.lg)
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AppRadius.lg)
            .shadow(color: .purple.opacity(0.3), radius: 8, y: 4)
        }
    }
}

// MARK: - 임신 정보 없을 때

struct PregnancySetupView: View {
    let onSetup: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.purple)

            Text("임신 정보 등록")
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)

            Text("마지막 생리일을 입력하여\n임신 주차와 출산 예정일을 계산합니다")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: onSetup) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("임신 정보 입력")
                }
                .font(AppTypography.headline)
                .foregroundColor(.white)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.md)
                .background(Color.purple)
                .cornerRadius(AppRadius.lg)
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}

// MARK: - 임신 정보 입력 시트

struct PregnancySetupSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var pregnancyManager: PregnancyManager

    @State private var babyName = ""
    @State private var lastPeriodDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("아기 태명") {
                    TextField("태명을 입력하세요", text: $babyName)
                }

                Section("마지막 생리 시작일 (LMP)") {
                    DatePicker(
                        "날짜",
                        selection: $lastPeriodDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }

                Section {
                    Button(action: {
                        pregnancyManager.startPregnancy(
                            babyName: babyName.isEmpty ? nil : babyName,
                            lastPeriodDate: lastPeriodDate
                        )
                        dismiss()
                    }) {
                        Text("등록")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.purple)
                    }
                }
            }
            .navigationTitle("임신 정보 입력")
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

// MARK: - 태명 수정 시트

struct BabyNameEditSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var pregnancyManager: PregnancyManager

    @State private var babyName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("태명") {
                    TextField("태명을 입력하세요", text: $babyName)
                }

                Section {
                    Button(action: {
                        pregnancyManager.updateBabyName(babyName)
                        dismiss()
                    }) {
                        Text("저장")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.purple)
                    }
                }
            }
            .navigationTitle("태명 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            babyName = pregnancyManager.pregnancyInfo?.babyName ?? ""
        }
    }
}

// MARK: - 검진 추가 시트

struct CheckupAddSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var pregnancyManager: PregnancyManager

    @State private var title = ""
    @State private var scheduledDate = Date()
    @State private var checkupType: CheckupType = .regular

    var body: some View {
        NavigationStack {
            Form {
                Section("검진 정보") {
                    TextField("검진 제목", text: $title)

                    DatePicker(
                        "예정일",
                        selection: $scheduledDate,
                        displayedComponents: .date
                    )

                    Picker("검진 종류", selection: $checkupType) {
                        ForEach(CheckupType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }

                Section {
                    Button(action: {
                        let checkup = CheckupSchedule(
                            title: title,
                            scheduledDate: scheduledDate,
                            checkupType: checkupType
                        )
                        pregnancyManager.addCheckup(checkup)
                        dismiss()
                    }) {
                        Text("추가")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.purple)
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("검진 추가")
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

#Preview {
    PregnancyPhaseView()
        .environmentObject(PregnancyManager())
        .environmentObject(AppState())
        .environmentObject(UserProfileManager())
}
