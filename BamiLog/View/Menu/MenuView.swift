//
//  MenuView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/01.
//  Updated with unified design system
//

import SwiftUI

enum ButtonType {
    case milk
    case feeding
    case diaper
    case sleep
}

struct MenuView: View {

    @EnvironmentObject var appState: AppState

    @State var milkRecords: [MilkRecord] = []

    // MARK: View Properties
    @State var isShow: Bool = false
    @State var isTableShow: Bool = false
    @State var isBathTimerShow: Bool = false
    @State var isSoundViewShow: Bool = false
    @State var buttonType: ButtonType?
    @State var showFeedingTypeSelection: Bool = false

    @State var showLoginPage: Bool = false
    @AppStorage("loginStatus") var loginStatus = false

    // 로그인 제안 관련
    @State var showLoginSuggestion: Bool = false
    @AppStorage("lastLoginSuggestionRecordCount") var lastLoginSuggestionRecordCount: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                // 배경
                AppColors.gradient1
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        // MARK: Summary Statistics
                        SummaryStatsCard(
                            records: milkRecords,
                            onGenerateSampleData: generateSampleData,
                            onFeedingTap: {
                                showFeedingTypeSelection = true
                            },
                            onSleepTap: {
                                buttonType = .sleep
                                isShow = true
                            },
                            onDiaperTap: {
                                buttonType = .diaper
                                isShow = true
                            }
                        )
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.sm)

                        // MARK: 로그인 제안 배너
                        if showLoginSuggestion && !loginStatus {
                            LoginSuggestionBanner(
                                onLoginTap: {
                                    // CoworkView로 이동
                                    showLoginPage = true
                                },
                                onDismiss: {
                                    showLoginSuggestion = false
                                    lastLoginSuggestionRecordCount = milkRecords.count
                                }
                            )
                            .padding(.horizontal, AppSpacing.md)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // MARK: 기능 섹션
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            SectionHeader("아기 돌봄")
                                .padding(.horizontal, AppSpacing.md)

                            // 기타 기능
                            HStack(spacing: AppSpacing.md) {
                                // 목욕
                                MenuIconButton(
                                    icon: "drop.fill",
                                    label: "목욕",
                                    color: AppColors.info
                                ) {
                                    isBathTimerShow.toggle()
                                }

                                // 소리
                                MenuIconButton(
                                    icon: "music.note",
                                    label: "자장가",
                                    color: Color(red: 0.8, green: 0.7, blue: 0.9)
                                ) {
                                    isSoundViewShow.toggle()
                                }
                            }
                            .padding(.horizontal, AppSpacing.md)

                            // 기록 보기 버튼
                            VStack(spacing: AppSpacing.sm) {
                                AppButton(
                                    "기록 보기",
                                    icon: "chart.bar.fill",
                                    color: AppColors.phase3,
                                    fullWidth: true
                                ) {
                                    isTableShow.toggle()
                                }
                            }
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.top, AppSpacing.sm)
                        }

                        Spacer(minLength: AppSpacing.xl)
                    }
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
                    NavigationLink {
                        CoworkView(showLoginPage: $showLoginPage)
                    } label: {
                        Image(systemName: "person.2.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $isShow) {
            RecordView(buttonType: $buttonType, isShow: $isShow)
        }
        .sheet(isPresented: $isTableShow) {
            StaticsView(isTableShow: $isTableShow)
        }
        .sheet(isPresented: $isBathTimerShow) {
            BathTimerView(isBathTimerShow: $isBathTimerShow)
        }
        .fullScreenCover(isPresented: $isSoundViewShow) {
            SoundView(isSoundViewShow: $isSoundViewShow)
        }
        .sheet(isPresented: $showLoginPage) {
            NavigationStack {
                CoworkView(showLoginPage: $showLoginPage)
                    .navigationTitle("협업")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("닫기") {
                                showLoginPage = false
                            }
                        }
                    }
            }
        }
        .confirmationDialog("수유 종류 선택", isPresented: $showFeedingTypeSelection) {
            Button("분유") {
                buttonType = .milk
                isShow = true
            }
            Button("모유") {
                buttonType = .feeding
                isShow = true
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("어떤 수유를 기록할까요?")
        }
        .onAppear {
            loginStatus = UserDefaults.standard.bool(forKey: "loginStatus")

            // Load milk records for statistics
            PersistenceManager.retrieveFavorites(key: .feed) { result in
                switch result {
                case .success(let records):
                    milkRecords = records
                    // 로그인 제안 표시 여부 확인
                    checkLoginSuggestion()
                case .failure(_):
                    milkRecords = []
                }
            }
        }
    }

    // MARK: - Generate Sample Data
    func generateSampleData() {
        var sampleRecords: [MilkRecord] = []
        let calendar = Calendar.current
        let now = Date()

        // 지난 3일간의 샘플 데이터 생성
        for dayOffset in (0...2).reversed() {
            guard let dayStart = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }

            // 하루에 6-8회 수유 (약 2-4시간 간격)
            let feedingCount = Int.random(in: 6...8)
            for feedingIndex in 0..<feedingCount {
                let hourOffset = feedingIndex * 3 + Int.random(in: -1...1) // 약 3시간 간격
                guard let feedingTime = calendar.date(byAdding: .hour, value: hourOffset, to: dayStart) else { continue }

                // 분유와 모유 번갈아가며
                if feedingIndex % 2 == 0 {
                    // 분유 수유
                    let record = MilkRecord(
                        startTime: feedingTime,
                        milkType: .powder,
                        milkQuantity: Int.random(in: 80...120)
                    )
                    sampleRecords.append(record)
                } else {
                    // 모유 수유
                    let record = MilkRecord(
                        startTime: feedingTime,
                        feedingTime: Int.random(in: 15...30)
                    )
                    sampleRecords.append(record)
                }
            }

            // 하루에 3-4회 수면 기록
            let sleepCount = Int.random(in: 3...4)
            for sleepIndex in 0..<sleepCount {
                let hourOffset = sleepIndex * 6 + Int.random(in: 0...2)
                guard let sleepTime = calendar.date(byAdding: .hour, value: hourOffset, to: dayStart) else { continue }

                let record = MilkRecord(
                    startTime: sleepTime,
                    sleepTime: Int.random(in: 60...180) // 1-3시간
                )
                sampleRecords.append(record)
            }

            // 하루에 5-7회 기저귀 교체
            let diaperCount = Int.random(in: 5...7)
            for diaperIndex in 0..<diaperCount {
                let hourOffset = diaperIndex * 3 + Int.random(in: 0...1)
                guard let diaperTime = calendar.date(byAdding: .hour, value: hourOffset, to: dayStart) else { continue }

                let record = MilkRecord(
                    startTime: diaperTime,
                    diaperPee: true,
                    diaperPoo: Bool.random()
                )
                sampleRecords.append(record)
            }
        }

        // 생성된 샘플 데이터 저장
        PersistenceManager.save(favorites: sampleRecords, key: .feed)

        // 상태 업데이트
        milkRecords = sampleRecords

        print("✅ 샘플 데이터 생성 완료: \(sampleRecords.count)개 기록")
    }

    // MARK: - Check Login Suggestion
    func checkLoginSuggestion() {
        // 이미 로그인되어 있으면 제안하지 않음
        guard !loginStatus else { return }

        // 기록이 충분히 있는지 확인 (최소 5개 이상)
        guard milkRecords.count >= 5 else { return }

        // 마지막으로 제안한 이후 10개 이상 새 기록이 추가되었는지 확인
        let recordsSinceLastSuggestion = milkRecords.count - lastLoginSuggestionRecordCount

        if recordsSinceLastSuggestion >= 10 {
            // 애니메이션과 함께 제안 표시
            withAnimation {
                showLoginSuggestion = true
            }
        }
    }
}

// MARK: - Menu Icon Button Component
struct MenuIconButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 70, height: 70)

                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 60, height: 60)

                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(color)
                }

                Text(label)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Summary Statistics Card
struct SummaryStatsCard: View {
    let records: [MilkRecord]
    let onGenerateSampleData: () -> Void
    let onFeedingTap: () -> Void
    let onSleepTap: () -> Void
    let onDiaperTap: () -> Void

    // 타이머를 위한 현재 시간 상태
    @State private var currentTime = Date()
    @State private var feedingTimer: Timer?

    // 오늘 기록 필터링
    var todayRecords: [MilkRecord] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return records.filter { record in
            calendar.isDate(record.startTime, inSameDayAs: today)
        }
    }

    // 수유 횟수 (분유 + 모유)
    var feedingCount: Int {
        todayRecords.filter { $0.milkType != nil || $0.feedingTime != nil }.count
    }

    // 마지막 수유 시간
    var lastFeedingTime: String {
        let feedingRecords = todayRecords.filter { $0.milkType != nil || $0.feedingTime != nil }
        guard let lastFeeding = feedingRecords.sorted(by: { $0.startTime > $1.startTime }).first else {
            return "-"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: lastFeeding.startTime)
    }

    // 총 수면 시간 (분)
    var totalSleepMinutes: Int {
        todayRecords.compactMap { $0.sleepTime }.reduce(0, +)
    }

    // 기저귀 교체 횟수
    var diaperChangeCount: Int {
        todayRecords.filter { $0.diaperPee != nil || $0.diaperPoo != nil }.count
    }

    // 패턴 분석: 평균 수유 간격 (분)
    var averageFeedingInterval: Int? {
        let feedingRecords = records.filter { $0.milkType != nil || $0.feedingTime != nil }
            .sorted(by: { $0.startTime < $1.startTime })

        guard feedingRecords.count >= 2 else { return nil }

        var intervals: [TimeInterval] = []
        for i in 0..<(feedingRecords.count - 1) {
            let interval = feedingRecords[i + 1].startTime.timeIntervalSince(feedingRecords[i].startTime)
            intervals.append(interval)
        }

        let averageSeconds = intervals.reduce(0, +) / Double(intervals.count)
        return Int(averageSeconds / 60) // 분 단위
    }

    // 다음 수유 예상 시간
    var nextFeedingPrediction: String {
        guard let avgInterval = averageFeedingInterval else { return "데이터 부족" }

        let feedingRecords = records.filter { $0.milkType != nil || $0.feedingTime != nil }
        guard let lastFeeding = feedingRecords.sorted(by: { $0.startTime > $1.startTime }).first else {
            return "데이터 없음"
        }

        let nextTime = lastFeeding.startTime.addingTimeInterval(TimeInterval(avgInterval * 60))
        let now = Date()

        if nextTime < now {
            return "곧 필요"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: nextTime)
    }

    // 다음 수유까지 남은 시간 (실시간 업데이트)
    var timeUntilNextFeeding: String? {
        guard let avgInterval = averageFeedingInterval else { return nil }

        let feedingRecords = records.filter { $0.milkType != nil || $0.feedingTime != nil }
        guard let lastFeeding = feedingRecords.sorted(by: { $0.startTime > $1.startTime }).first else {
            return nil
        }

        let nextTime = lastFeeding.startTime.addingTimeInterval(TimeInterval(avgInterval * 60))
        let now = currentTime // 타이머로 업데이트되는 현재 시간 사용
        let remainingSeconds = Int(nextTime.timeIntervalSince(now))
        let remainingMinutes = remainingSeconds / 60

        if remainingMinutes <= 0 {
            return "곧 필요"
        } else if remainingMinutes < 60 {
            let seconds = remainingSeconds % 60
            return "\(remainingMinutes)분 \(seconds)초 후"
        } else {
            let hours = remainingMinutes / 60
            let mins = remainingMinutes % 60
            return "\(hours)시간 \(mins)분 후"
        }
    }

    var body: some View {
        AppCard {
            VStack(spacing: AppSpacing.md) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.phase3)

                    Text("오늘의 요약")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    Text("24시간")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Divider()

                // 통계 그리드
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: AppSpacing.md) {
                    // 수유 횟수 (탭 가능)
                    Button(action: onFeedingTap) {
                        StatItemView(
                            icon: "bottle.fill",
                            color: AppColors.warning,
                            label: "수유",
                            value: "\(feedingCount)회",
                            subtitle: lastFeedingTime != "-" ? "마지막: \(lastFeedingTime)" : nil
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // 수면 시간 (탭 가능)
                    Button(action: onSleepTap) {
                        StatItemView(
                            icon: "moon.stars.fill",
                            color: Color(red: 0.5, green: 0.6, blue: 0.9),
                            label: "수면",
                            value: formatSleepTime(totalSleepMinutes),
                            subtitle: totalSleepMinutes > 0 ? "총 \(totalSleepMinutes)분" : nil
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // 기저귀 (탭 가능)
                    Button(action: onDiaperTap) {
                        StatItemView(
                            icon: "squareshape.fill",
                            color: Color(red: 0.7, green: 0.5, blue: 0.4),
                            label: "기저귀",
                            value: "\(diaperChangeCount)회",
                            subtitle: nil
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // 전체 활동 (탭 불가)
                    StatItemView(
                        icon: "checkmark.circle.fill",
                        color: AppColors.success,
                        label: "전체 활동",
                        value: "\(todayRecords.count)회",
                        subtitle: nil
                    )
                }

                // 패턴 기반 예측
                if averageFeedingInterval != nil {
                    Divider()
                        .padding(.top, AppSpacing.xs)

                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.phase3)

                            Text("다음 수유 예측")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        HStack {
                            Text("예상 시간: \(nextFeedingPrediction)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)

                            if let timeUntil = timeUntilNextFeeding {
                                Spacer()
                                Text(timeUntil)
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.warning)
                                    .padding(.horizontal, AppSpacing.sm)
                                    .padding(.vertical, 4)
                                    .background(AppColors.warning.opacity(0.1))
                                    .cornerRadius(AppRadius.sm)
                            }
                        }

                        if let avgInterval = averageFeedingInterval {
                            Text("평균 \(avgInterval)분 간격으로 수유 중")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }

                // 샘플 데이터 생성 버튼 (데이터가 없을 때만 표시)
                if records.isEmpty {
                    Divider()
                        .padding(.top, AppSpacing.xs)

                    Button(action: onGenerateSampleData) {
                        HStack {
                            Image(systemName: "wand.and.stars.inverse")
                                .font(.system(size: 14))

                            Text("샘플 데이터 생성하기")
                                .font(AppTypography.caption)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(AppColors.phase3)
                        .padding(.vertical, AppSpacing.xs)
                        .padding(.horizontal, AppSpacing.sm)
                        .background(AppColors.phase3.opacity(0.1))
                        .cornerRadius(AppRadius.md)
                    }
                }
            }
        }
        .onAppear {
            feedingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                currentTime = Date()
            }
        }
        .onDisappear {
            feedingTimer?.invalidate()
            feedingTimer = nil
        }
    }

    func formatSleepTime(_ minutes: Int) -> String {
        if minutes == 0 { return "0시간" }
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 && mins > 0 {
            return "\(hours)시간 \(mins)분"
        } else if hours > 0 {
            return "\(hours)시간"
        } else {
            return "\(mins)분"
        }
    }
}

// MARK: - Stat Item Component
struct StatItemView: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    let subtitle: String?

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)

                Text(label)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(color.opacity(0.1))
        .cornerRadius(AppRadius.md)
    }
}

// MARK: - Login Suggestion Banner
struct LoginSuggestionBanner: View {
    let onLoginTap: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primary)

                        Text("배우자와 함께 기록하기")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }

                    Text("로그인하고 QR코드로 배우자와 실시간 공유하세요")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            HStack(spacing: AppSpacing.sm) {
                Button(action: onLoginTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.system(size: 14))
                        Text("로그인하기")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.primary)
                    .cornerRadius(AppRadius.sm)
                }

                Button(action: onDismiss) {
                    Text("나중에")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            LinearGradient(
                colors: [
                    AppColors.primary.opacity(0.1),
                    AppColors.primary.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(AppRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
