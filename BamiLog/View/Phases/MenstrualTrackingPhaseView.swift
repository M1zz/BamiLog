//
//  MenstrualTrackingPhaseView.swift
//  BamiLog
//
//  Created by Claude on 12/16/25.
//

import SwiftUI

struct MenstrualTrackingPhaseView: View {
    @EnvironmentObject var menstrualManager: MenstrualCycleManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userProfileManager: UserProfileManager

    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showSymptomSheet = false
    @State private var showFlowSheet = false
    @State private var showHistorySheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.pink.opacity(0.1),
                        AppColors.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // 현재 상태 카드
                        CurrentStatusCard()

                        // 캘린더
                        MenstrualCalendarView(
                            currentMonth: $currentMonth,
                            selectedDate: $selectedDate
                        )

                        // 선택된 날짜 정보
                        SelectedDateInfo(
                            selectedDate: selectedDate,
                            onAddFlow: { showFlowSheet = true },
                            onAddSymptom: { showSymptomSheet = true }
                        )

                        // 통계 카드
                        CycleStatisticsCard()

                        // 다음 예측 카드
                        PredictionCard()

                        Spacer(minLength: AppSpacing.xl)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.md)
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

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showHistorySheet = true
                    }) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("생리 주기")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            .sheet(isPresented: $showFlowSheet) {
                FlowLevelSheet(date: selectedDate)
            }
            .sheet(isPresented: $showSymptomSheet) {
                SymptomSheet(date: selectedDate)
            }
            .sheet(isPresented: $showHistorySheet) {
                CycleHistoryView()
            }
        }
    }
}

// MARK: - 현재 상태 카드

struct CurrentStatusCard: View {
    @EnvironmentObject var menstrualManager: MenstrualCycleManager

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            if let current = menstrualManager.currentCycle {
                // 진행 중
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("생리 진행 중")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)

                        Text("\(periodDay)일째")
                            .font(AppTypography.title2)
                            .foregroundColor(.pink)
                    }

                    Spacer()

                    Button(action: {
                        menstrualManager.endPeriod(cycle: current)
                    }) {
                        HStack {
                            Image(systemName: "stop.circle.fill")
                            Text("종료")
                        }
                        .font(AppTypography.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(Color.pink)
                        .cornerRadius(AppRadius.md)
                    }
                }
            } else {
                // 진행 중 아님
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("생리 기록")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)

                        if let next = menstrualManager.nextPeriodPrediction {
                            Text("예정일까지 \(daysUntil(next))일")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        } else {
                            Text("시작 버튼을 눌러 기록하세요")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    Button(action: {
                        menstrualManager.startPeriod()
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("시작")
                        }
                        .font(AppTypography.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(Color.pink)
                        .cornerRadius(AppRadius.md)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private var periodDay: Int {
        guard let current = menstrualManager.currentCycle else { return 0 }
        return Calendar.current.dateComponents([.day], from: current.startDate, to: Date()).day ?? 0 + 1
    }

    private func daysUntil(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }
}

// MARK: - 캘린더 뷰

struct MenstrualCalendarView: View {
    @EnvironmentObject var menstrualManager: MenstrualCycleManager
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date

    private let calendar = Calendar.current
    private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // 월 선택
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textPrimary)
                }

                Spacer()

                Text(monthYearString)
                    .font(AppTypography.title3)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            .padding(.horizontal, AppSpacing.sm)

            // 요일 헤더
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // 날짜 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            status: getStatus(for: date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: currentMonth)
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [Date?] = []
        var currentDate = monthFirstWeek.start

        while days.count < 42 { // 6주 * 7일
            if calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month) {
                days.append(currentDate)
            } else {
                days.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return days
    }

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func getStatus(for date: Date) -> DayStatus {
        // 생리 중인지 확인
        for cycle in menstrualManager.cycles {
            if calendar.isDate(date, inSameDayAs: cycle.startDate) {
                return .periodStart
            }

            if let endDate = cycle.endDate,
               date >= cycle.startDate && date <= endDate {
                return .period
            } else if cycle.endDate == nil && date >= cycle.startDate && date <= Date() {
                return .period
            }
        }

        // 배란 예측
        if let ovulation = menstrualManager.predictOvulation() {
            if calendar.isDate(date, inSameDayAs: ovulation.predictedOvulationDate) {
                return .ovulation
            }
            if date >= ovulation.fertileWindowStart && date <= ovulation.fertileWindowEnd {
                return .fertile
            }
        }

        // 증상이 있는지 확인
        let (_, symptoms, _) = menstrualManager.getDataForDate(date)
        if !symptoms.isEmpty {
            return .symptom
        }

        return .normal
    }
}

enum DayStatus {
    case normal
    case period
    case periodStart
    case ovulation
    case fertile
    case symptom
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let status: DayStatus

    var body: some View {
        ZStack {
            // 배경
            Circle()
                .fill(backgroundColor)

            // 오늘 표시
            if isToday && !isSelected {
                Circle()
                    .stroke(Color.pink, lineWidth: 2)
            }

            // 선택 표시
            if isSelected {
                Circle()
                    .stroke(Color.pink, lineWidth: 3)
            }

            // 날짜
            Text("\(Calendar.current.component(.day, from: date))")
                .font(AppTypography.caption)
                .foregroundColor(textColor)

            // 상태 점
            if status != .normal && !isSelected {
                VStack {
                    Spacer()
                    Circle()
                        .fill(statusColor)
                        .frame(width: 4, height: 4)
                        .offset(y: -4)
                }
            }
        }
        .frame(height: 44)
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.pink.opacity(0.3)
        }

        switch status {
        case .period, .periodStart:
            return Color.pink.opacity(0.2)
        case .ovulation:
            return Color.purple.opacity(0.2)
        case .fertile:
            return Color.green.opacity(0.1)
        case .symptom:
            return Color.orange.opacity(0.1)
        case .normal:
            return Color.clear
        }
    }

    private var textColor: Color {
        if isSelected {
            return .pink
        }
        return AppColors.textPrimary
    }

    private var statusColor: Color {
        switch status {
        case .period, .periodStart:
            return .pink
        case .ovulation:
            return .purple
        case .fertile:
            return .green
        case .symptom:
            return .orange
        case .normal:
            return .clear
        }
    }
}

// MARK: - 선택된 날짜 정보

struct SelectedDateInfo: View {
    @EnvironmentObject var menstrualManager: MenstrualCycleManager
    let selectedDate: Date
    let onAddFlow: () -> Void
    let onAddSymptom: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text(formatDate(selectedDate))
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()
            }

            let data = menstrualManager.getDataForDate(selectedDate)

            // 출혈량
            if let flowLevel = data.flowLevel {
                HStack {
                    Image(systemName: flowLevel.icon)
                        .foregroundColor(.pink)
                    Text("출혈량: \(flowLevel.rawValue)")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                }
            }

            // 증상
            if !data.symptoms.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("증상")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)

                    ForEach(data.symptoms) { symptom in
                        HStack {
                            Image(systemName: symptom.type.icon)
                                .foregroundColor(.orange)
                            Text(symptom.type.rawValue)
                                .font(AppTypography.body)
                            Text("(\(symptom.severity)/5)")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                        }
                    }
                }
            }

            // 버튼
            HStack(spacing: AppSpacing.sm) {
                Button(action: onAddFlow) {
                    HStack {
                        Image(systemName: "drop.fill")
                        Text("출혈량 기록")
                    }
                    .font(AppTypography.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(Color.pink)
                    .cornerRadius(AppRadius.md)
                }

                Button(action: onAddSymptom) {
                    HStack {
                        Image(systemName: "note.text.badge.plus")
                        Text("증상 기록")
                    }
                    .font(AppTypography.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(Color.orange)
                    .cornerRadius(AppRadius.md)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

// MARK: - 통계 카드

struct CycleStatisticsCard: View {
    @EnvironmentObject var menstrualManager: MenstrualCycleManager

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("통계")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }

            HStack(spacing: AppSpacing.lg) {
                MenstrualStatItem(
                    title: "평균 주기",
                    value: menstrualManager.averageCycleLength.map { "\($0)일" } ?? "-",
                    icon: "calendar"
                )

                Divider()
                    .frame(height: 40)

                MenstrualStatItem(
                    title: "평균 기간",
                    value: menstrualManager.averagePeriodLength.map { "\($0)일" } ?? "-",
                    icon: "clock"
                )

                Divider()
                    .frame(height: 40)

                MenstrualStatItem(
                    title: "총 주기",
                    value: "\(menstrualManager.cycles.count)회",
                    icon: "chart.bar"
                )
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

struct MenstrualStatItem: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.pink)

            Text(value)
                .font(AppTypography.title3)
                .foregroundColor(AppColors.textPrimary)

            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 예측 카드

struct PredictionCard: View {
    @EnvironmentObject var menstrualManager: MenstrualCycleManager

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("예측")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }

            if let nextPeriod = menstrualManager.nextPeriodPrediction {
                PredictionRow(
                    icon: "calendar.badge.clock",
                    title: "다음 생리 예정일",
                    value: formatDate(nextPeriod),
                    color: .pink
                )
            }

            if let ovulation = menstrualManager.predictOvulation() {
                PredictionRow(
                    icon: "heart.circle.fill",
                    title: "배란 예정일",
                    value: formatDate(ovulation.predictedOvulationDate),
                    color: .purple
                )

                PredictionRow(
                    icon: "leaf.fill",
                    title: "가임기",
                    value: "\(formatDate(ovulation.fertileWindowStart)) ~ \(formatDate(ovulation.fertileWindowEnd))",
                    color: .green
                )

                HStack {
                    Text("신뢰도: \(Int(ovulation.confidence * 100))%")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                }
            }

            if menstrualManager.cycles.isEmpty {
                Text("더 많은 기록을 추가하면 정확한 예측을 제공합니다")
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, AppSpacing.md)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

struct PredictionRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                Text(value)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)
            }

            Spacer()
        }
    }
}

// MARK: - 출혈량 시트

struct FlowLevelSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var menstrualManager: MenstrualCycleManager
    let date: Date

    var body: some View {
        NavigationStack {
            List {
                ForEach(FlowLevel.allCases, id: \.self) { level in
                    Button(action: {
                        menstrualManager.updateFlowLevel(date: date, flowLevel: level)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: level.icon)
                                .foregroundColor(.pink)
                            Text(level.rawValue)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                        }
                        .padding(.vertical, AppSpacing.xs)
                    }
                }
            }
            .navigationTitle("출혈량 선택")
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

// MARK: - 증상 시트

struct SymptomSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var menstrualManager: MenstrualCycleManager
    let date: Date
    @State private var selectedType: SymptomType = .cramps
    @State private var severity: Int = 3

    var body: some View {
        NavigationStack {
            Form {
                Section("증상 종류") {
                    Picker("증상", selection: $selectedType) {
                        ForEach(SymptomType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }

                Section("심각도") {
                    VStack {
                        HStack {
                            Text("1")
                                .font(AppTypography.caption)
                            Spacer()
                            Text("\(severity)")
                                .font(AppTypography.title3)
                                .foregroundColor(.pink)
                            Spacer()
                            Text("5")
                                .font(AppTypography.caption)
                        }

                        Slider(value: Binding(
                            get: { Double(severity) },
                            set: { severity = Int($0) }
                        ), in: 1...5, step: 1)
                        .tint(.pink)
                    }
                }

                Section {
                    Button(action: {
                        menstrualManager.addSymptom(date: date, type: selectedType, severity: severity)
                        dismiss()
                    }) {
                        Text("저장")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.pink)
                    }
                }
            }
            .navigationTitle("증상 기록")
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

// MARK: - 히스토리 뷰

struct CycleHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var menstrualManager: MenstrualCycleManager

    var body: some View {
        NavigationStack {
            List {
                ForEach(menstrualManager.cycles) { cycle in
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        HStack {
                            Text(formatDate(cycle.startDate))
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.textPrimary)

                            if cycle.isOngoing {
                                Text("진행 중")
                                    .font(AppTypography.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, AppSpacing.xs)
                                    .padding(.vertical, 2)
                                    .background(Color.pink)
                                    .cornerRadius(4)
                            }

                            Spacer()
                        }

                        if let endDate = cycle.endDate {
                            Text("~ \(formatDate(endDate))")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        HStack(spacing: AppSpacing.md) {
                            if let period = cycle.periodLength {
                                Label("\(period)일", systemImage: "clock")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            if let cycleLen = cycle.cycleLength {
                                Label("주기 \(cycleLen)일", systemImage: "calendar")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            if !cycle.dailyLogs.isEmpty {
                                Label("\(cycle.dailyLogs.count)개 기록", systemImage: "note.text")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                    .padding(.vertical, AppSpacing.xs)
                }
                .onDelete(perform: deleteCycles)
            }
            .navigationTitle("기록 히스토리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func deleteCycles(at offsets: IndexSet) {
        offsets.forEach { index in
            let cycle = menstrualManager.cycles[index]
            menstrualManager.deleteCycle(cycle)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

#Preview {
    MenstrualTrackingPhaseView()
        .environmentObject(MenstrualCycleManager())
        .environmentObject(AppState())
        .environmentObject(UserProfileManager())
}
