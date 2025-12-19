//
//  RecordView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/01.
//  Updated with modern design system
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct RecordView: View {
    @Binding var buttonType: ButtonType?
    @Binding var isShow: Bool
    @State private var recordTime = Date()
    @State private var quantity: Int = 5
    @State private var milkType: MilkType = .natural
    @State private var feedingTime: Int = 5

    private let ref = Database.database().reference(withPath: "feed-history")

    @State private var sleepTime: Int = 3
    @State private var diaperPee: Bool = false
    @State private var diaperPoo: Bool = false

    // 패턴 분석용
    @State private var recentRecords: [MilkRecord] = []
    @State private var smartDefaults: SmartDefaults = SmartDefaults()
    @State private var useManualInput: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 컨텐츠
                    ScrollView {
                        contentSection
                            .padding(.horizontal, 12)
                            .padding(.top, 8)
                            .padding(.bottom, 12)
                    }

                    // 하단 고정 저장 버튼
                    VStack(spacing: 0) {
                        Divider()
                        saveButton
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(AppColors.cardBackground)
                    }
                }
            }
            .navigationTitle(currentTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: currentIcon)
                        .foregroundColor(currentColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShow = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .onAppear {
                useManualInput = false // 배너를 다시 보여주기 위해 리셋
                loadAndApplySmartDefaults()
            }
        }
    }

    // MARK: - Content Section
    @ViewBuilder
    private var contentSection: some View {
        VStack(spacing: 12) {
            // 스마트 제안 배너
            if hasSuggestion && !useManualInput {
                smartSuggestionBanner
            }

            // 입력 폼
            switch buttonType {
            case .milk:
                milkView
            case .feeding:
                feedingView
            case .sleep:
                sleepView
            case .diaper:
                diaperView
            case nil:
                Text("선택된 항목이 없습니다")
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    // MARK: - Smart Suggestion Banner
    @ViewBuilder
    private var smartSuggestionBanner: some View {
        VStack(spacing: 8) {
            // 제안 정보
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.warning)

                VStack(alignment: .leading, spacing: 2) {
                    Text("평소 패턴 기반 제안")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    Text(suggestionText)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()
            }

            // 빠른 선택 버튼
            HStack(spacing: 8) {
                // 제안대로 버튼
                Button(action: {
                    applySmartDefaults()
                    useManualInput = false
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                        Text(suggestionButtonText)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(currentColor)
                    .cornerRadius(8)
                }

                // 직접 입력 버튼
                Button(action: {
                    useManualInput = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                        Text("직접 입력")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(AppColors.warning.opacity(0.1))
        .cornerRadius(AppRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(AppColors.warning.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Helper Properties for Suggestions
    private var hasSuggestion: Bool {
        switch buttonType {
        case .milk:
            return smartDefaults.averageFeedingAmount != nil || smartDefaults.lastFeedingAmount != nil
        case .feeding:
            return smartDefaults.averageFeedingTime != nil || smartDefaults.lastFeedingTime != nil
        case .sleep:
            return smartDefaults.averageSleepTime != nil ||
                   smartDefaults.daySleepAverage != nil ||
                   smartDefaults.nightSleepAverage != nil
        case .diaper, nil:
            return false
        }
    }

    private var suggestionText: String {
        switch buttonType {
        case .milk:
            if let avg = smartDefaults.averageFeedingAmount {
                return "평균 \(avg)ml로 먹고 있어요"
            } else if let last = smartDefaults.lastFeedingAmount {
                return "지난번 \(last)ml 먹었어요"
            }
        case .feeding:
            if let avg = smartDefaults.averageFeedingTime {
                return "평균 \(avg)분 수유하고 있어요"
            } else if let last = smartDefaults.lastFeedingTime {
                return "지난번 \(last)분 수유했어요"
            }
        case .sleep:
            let hour = Calendar.current.component(.hour, from: Date())
            if hour >= 6 && hour < 18 {
                if let daySleep = smartDefaults.daySleepAverage {
                    return "낮에는 평균 \(daySleep)분 자요"
                }
            } else {
                if let nightSleep = smartDefaults.nightSleepAverage {
                    return "밤에는 평균 \(nightSleep)분 자요"
                }
            }
            if let avg = smartDefaults.averageSleepTime {
                return "평균 \(avg)분 자고 있어요"
            }
        case .diaper, nil:
            break
        }
        return ""
    }

    private var suggestionButtonText: String {
        switch buttonType {
        case .milk:
            if let avg = smartDefaults.averageFeedingAmount {
                return "\(avg)ml로 입력"
            } else if let last = smartDefaults.lastFeedingAmount {
                return "\(last)ml로 입력"
            }
        case .feeding:
            if let avg = smartDefaults.averageFeedingTime {
                return "\(avg)분으로 입력"
            } else if let last = smartDefaults.lastFeedingTime {
                return "\(last)분으로 입력"
            }
        case .sleep:
            let hour = Calendar.current.component(.hour, from: Date())
            if hour >= 6 && hour < 18 {
                if let daySleep = smartDefaults.daySleepAverage {
                    return "\(daySleep)분으로 입력"
                }
            } else {
                if let nightSleep = smartDefaults.nightSleepAverage {
                    return "\(nightSleep)분으로 입력"
                }
            }
            if let avg = smartDefaults.averageSleepTime {
                return "\(avg)분으로 입력"
            }
        case .diaper, nil:
            break
        }
        return "이대로 입력"
    }

    // MARK: - Milk View
    @ViewBuilder
    private var milkView: some View {
        VStack(spacing: 6) {
            // 종류 선택
            HStack {
                Text("종류")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 70, alignment: .leading)

                Picker("종류", selection: $milkType) {
                    Text("모유").tag(MilkType.natural)
                    Text("분유").tag(MilkType.powder)
                }
                .pickerStyle(.segmented)
            }
            .padding(.vertical, 8)

            Divider()

            // 먹인 양
            HStack(spacing: 12) {
                Text("먹인 양")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 70, alignment: .leading)

                Picker("먹인 양", selection: $quantity) {
                    ForEach(1...30, id: \.self) { number in
                        Text("\(number*10)ml").tag(number)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 80)
            }

            Divider()

            // 시간 선택
            HStack(spacing: 12) {
                Text("먹은 시간")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 70, alignment: .leading)

                DatePicker("", selection: $recordTime)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            .padding(.vertical, 8)
        }
        .padding(12)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Feeding View
    @ViewBuilder
    private var feedingView: some View {
        VStack(spacing: 6) {
            // 직수 시간
            HStack(spacing: 12) {
                Text("직수 시간")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 70, alignment: .leading)

                Picker("직수 시간", selection: $feedingTime) {
                    ForEach(1...70, id: \.self) { number in
                        Text("\(number)분").tag(number)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 80)
            }

            Divider()

            // 끝난 시간
            HStack(spacing: 12) {
                Text("끝난 시간")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 70, alignment: .leading)

                DatePicker("", selection: $recordTime)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            .padding(.vertical, 8)
        }
        .padding(12)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Sleep View
    @ViewBuilder
    private var sleepView: some View {
        VStack(spacing: 6) {
            // 잔 시간
            HStack(spacing: 12) {
                Text("잔 시간")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 70, alignment: .leading)

                Picker("잔 시간", selection: $sleepTime) {
                    ForEach(1...30, id: \.self) { number in
                        Text("\(number*5)분").tag(number)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 80)
            }

            Divider()

            // 잠든 시간
            HStack(spacing: 12) {
                Text("잠든 시간")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 70, alignment: .leading)

                DatePicker("", selection: $recordTime)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            .padding(.vertical, 8)
        }
        .padding(12)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Diaper View
    @ViewBuilder
    private var diaperView: some View {
        VStack(spacing: 6) {
            // 배변 상태
            HStack(spacing: 12) {
                Text("배변 상태")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 70, alignment: .leading)

                HStack(spacing: 10) {
                    // 소변 버튼
                    Button(action: { diaperPee.toggle() }) {
                        HStack(spacing: 6) {
                            Image(systemName: diaperPee ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                            Text("소변")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(diaperPee ? AppColors.info : AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(diaperPee ? AppColors.info.opacity(0.15) : AppColors.secondaryBackground)
                        .cornerRadius(8)
                    }

                    // 대변 버튼
                    Button(action: { diaperPoo.toggle() }) {
                        HStack(spacing: 6) {
                            Image(systemName: diaperPoo ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                            Text("대변")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(diaperPoo ? AppColors.warning : AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(diaperPoo ? AppColors.warning.opacity(0.15) : AppColors.secondaryBackground)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical, 8)

            Divider()

            // 갈아준 시간
            HStack(spacing: 12) {
                Text("갈아준 시간")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 70, alignment: .leading)

                DatePicker("", selection: $recordTime)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            .padding(.vertical, 8)
        }
        .padding(12)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Save Button
    @ViewBuilder
    private var saveButton: some View {
        AppButton(
            "저장하기",
            icon: "checkmark.circle.fill",
            color: currentColor,
            fullWidth: true
        ) {
            saveRecord()
        }
    }

    // MARK: - Helper Properties
    private var currentTitle: String {
        switch buttonType {
        case .milk: return "분유 기록"
        case .feeding: return "모유 기록"
        case .sleep: return "수면 기록"
        case .diaper: return "기저귀 기록"
        case nil: return ""
        }
    }

    private var currentIcon: String {
        switch buttonType {
        case .milk: return "bottle.fill"
        case .feeding: return "heart.circle.fill"
        case .sleep: return "moon.stars.fill"
        case .diaper: return "squareshape.fill"
        case nil: return "questionmark"
        }
    }

    private var currentColor: Color {
        switch buttonType {
        case .milk: return AppColors.warning
        case .feeding: return Color(red: 0.9, green: 0.6, blue: 0.8)
        case .sleep: return AppColors.info
        case .diaper: return Color(red: 0.7, green: 0.5, blue: 0.4)
        case nil: return AppColors.textSecondary
        }
    }

    // MARK: - Save Record
    private func saveRecord() {
        switch buttonType {
        case .milk:
            let milkRecord = MilkRecord(
                startTime: recordTime,
                startTimeDate: recordTime.formatted("yyyy-MM-dd"),
                milkQuantity: quantity * 10
            )
            saveToStorage(milkRecord)

        case .feeding:
            let feedingRecord = MilkRecord(
                startTime: recordTime.adding(minutes: feedingTime),
                startTimeDate: recordTime.adding(minutes: feedingTime).formatted("yyyy-MM-dd"),
                feedingTime: feedingTime
            )
            saveToStorage(feedingRecord)

        case .sleep:
            let sleepRecord = MilkRecord(
                startTime: recordTime,
                startTimeDate: recordTime.formatted("yyyy-MM-dd"),
                sleepTime: sleepTime * 5
            )
            saveToStorage(sleepRecord)

        case .diaper:
            let diaperRecord = MilkRecord(
                startTime: recordTime,
                startTimeDate: recordTime.formatted("yyyy-MM-dd"),
                diaperPee: diaperPee,
                diaperPoo: diaperPoo
            )
            saveToStorage(diaperRecord)

        case nil:
            break
        }

        isShow = false
    }

    private func saveToStorage(_ record: MilkRecord) {
        print("💾 기록 저장 시작...")

        // 1. 로컬 저장 (최우선 - 항상 실행)
        PersitenceManager.updateWith(favorite: record, actionType: .add, key: .feed) { error in
            if let error = error {
                print("❌ 로컬 저장 실패: \(error)")
            } else {
                print("✅ 로컬 저장 성공")
            }
        }

        // 2. Firebase 동기화 시도 (로그인 되어있으면)
        saveFeedHistory(data: record)
    }

    private func saveFeedHistory(data: MilkRecord) {
        let user = Auth.auth().currentUser
        guard user != nil else {
            print("ℹ️ 로그인 안 됨 - Firebase 저장 건너뜀 (로컬만 저장됨)")
            return
        }

        print("☁️ Firebase 동기화 시작...")
        let groupCode = UserDefaults.standard.string(forKey: "groupCode") ?? "error"
        let locationRef = ref.child(groupCode)

        // 로컬에서 모든 기록 가져오기
        PersitenceManager.retrieveFavorites(key: .feed) { result in
            switch result {
            case .success(let allRecords):
                do {
                    let jsonData = try JSONEncoder().encode(allRecords)
                    let jsonString = String(data: jsonData, encoding: .utf8)
                    locationRef.setValue(jsonString) { error, _ in
                        if let error = error {
                            print("❌ Firebase 저장 실패: \(error)")
                        } else {
                            print("✅ Firebase 동기화 성공: \(allRecords.count)개 기록")
                        }
                    }
                } catch {
                    print("❌ Firebase 인코딩 오류: \(error)")
                }
            case .failure(let error):
                print("❌ 로컬 데이터 읽기 실패: \(error)")
            }
        }
    }

    // MARK: - Smart Defaults
    private func loadAndApplySmartDefaults() {
        // 최근 기록 불러오기
        PersitenceManager.retrieveFavorites(key: .feed) { result in
            switch result {
            case .success(let records):
                recentRecords = records
                if let type = buttonType {
                    smartDefaults = SmartDefaults.analyze(from: records, for: type)
                    // 제안 배너만 표시하고, 사용자가 버튼을 눌러야 적용됨
                }
            case .failure(_):
                recentRecords = []
            }
        }
    }

    private func applySmartDefaults() {
        guard let type = buttonType else { return }

        switch type {
        case .milk:
            // 분유: 평균 수유량 또는 마지막 수유량 적용
            if let avg = smartDefaults.averageFeedingAmount {
                quantity = avg / 10 // Picker는 1~30이고 *10을 하므로
            } else if let last = smartDefaults.lastFeedingAmount {
                quantity = last / 10
            }

        case .feeding:
            // 모유: 평균 수유 시간 또는 마지막 수유 시간 적용
            if let avg = smartDefaults.averageFeedingTime {
                feedingTime = avg
            } else if let last = smartDefaults.lastFeedingTime {
                feedingTime = last
            }

        case .sleep:
            // 수면: 낮/밤 구분해서 평균 수면 시간 적용
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: Date())

            if hour >= 6 && hour < 18 {
                // 낮 시간대 (6시~18시)
                if let daySleep = smartDefaults.daySleepAverage {
                    sleepTime = daySleep / 5 // Picker는 *5를 하므로
                } else if let avg = smartDefaults.averageSleepTime {
                    sleepTime = avg / 5
                }
            } else {
                // 밤 시간대 (18시~6시)
                if let nightSleep = smartDefaults.nightSleepAverage {
                    sleepTime = nightSleep / 5
                } else if let avg = smartDefaults.averageSleepTime {
                    sleepTime = avg / 5
                }
            }

        case .diaper, nil:
            break
        }
    }
}

// MARK: - Extensions
// MARK: - Smart Defaults for Pattern-Based Input
struct SmartDefaults {
    var lastFeedingAmount: Int?
    var averageFeedingAmount: Int?
    var commonAmounts: [Int] = []
    var lastFeedingTime: Int?
    var averageFeedingTime: Int?
    var lastSleepTime: Int?
    var averageSleepTime: Int?
    var nightSleepAverage: Int?
    var daySleepAverage: Int?

    static func analyze(from records: [MilkRecord], for type: ButtonType) -> SmartDefaults {
        var defaults = SmartDefaults()

        switch type {
        case .milk, .feeding:
            // 수유 패턴 분석
            let feedingRecords = records.filter { $0.milkType != nil || $0.feedingTime != nil }
                .sorted(by: { $0.startTime > $1.startTime })

            // 마지막 수유량
            if let last = feedingRecords.first {
                defaults.lastFeedingAmount = last.milkQuantity
                defaults.lastFeedingTime = last.feedingTime
            }

            // 평균 수유량 (최근 10개)
            let recentAmounts = feedingRecords.prefix(10).compactMap { $0.milkQuantity }
            if !recentAmounts.isEmpty {
                defaults.averageFeedingAmount = recentAmounts.reduce(0, +) / recentAmounts.count
            }

            // 평균 수유 시간 (최근 10개)
            let recentTimes = feedingRecords.prefix(10).compactMap { $0.feedingTime }
            if !recentTimes.isEmpty {
                defaults.averageFeedingTime = recentTimes.reduce(0, +) / recentTimes.count
            }

            // 자주 사용하는 양 (최근 20개에서 상위 3개)
            let amounts = feedingRecords.prefix(20).compactMap { $0.milkQuantity }
            let amountCounts = Dictionary(grouping: amounts, by: { $0 })
                .mapValues { $0.count }
                .sorted { $0.value > $1.value }
            defaults.commonAmounts = Array(amountCounts.prefix(3).map { $0.key })

        case .sleep:
            // 수면 패턴 분석
            let sleepRecords = records.filter { $0.sleepTime != nil }
                .sorted(by: { $0.startTime > $1.startTime })

            // 마지막 수면 시간
            defaults.lastSleepTime = sleepRecords.first?.sleepTime

            // 평균 수면 시간
            let sleepTimes = sleepRecords.prefix(10).compactMap { $0.sleepTime }
            if !sleepTimes.isEmpty {
                defaults.averageSleepTime = sleepTimes.reduce(0, +) / sleepTimes.count
            }

            // 낮/밤 구분 (6시~18시 = 낮, 18시~6시 = 밤)
            let calendar = Calendar.current
            let daySleeps = sleepRecords.filter {
                let hour = calendar.component(.hour, from: $0.startTime)
                return hour >= 6 && hour < 18
            }.prefix(10).compactMap { $0.sleepTime }

            let nightSleeps = sleepRecords.filter {
                let hour = calendar.component(.hour, from: $0.startTime)
                return hour >= 18 || hour < 6
            }.prefix(10).compactMap { $0.sleepTime }

            if !daySleeps.isEmpty {
                defaults.daySleepAverage = daySleeps.reduce(0, +) / daySleeps.count
            }
            if !nightSleeps.isEmpty {
                defaults.nightSleepAverage = nightSleeps.reduce(0, +) / nightSleeps.count
            }

        case .diaper, nil:
            break
        }

        return defaults
    }
}

extension Date {
    public func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)!
        return formatter.string(from: self)
    }

    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: -minutes, to: self)!
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(buttonType: .constant(.milk), isShow: .constant(true))
    }
}
