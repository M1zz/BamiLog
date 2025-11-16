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
        }
    }

    // MARK: - Content Section
    @ViewBuilder
    private var contentSection: some View {
        switch buttonType {
        case .milk:
            milkView
        case .feeding:
            feedingView
        case .sleep:
            sleepView
        case .diaper:
            diaperView
        case .none:
            Text("선택된 항목이 없습니다")
                .foregroundColor(AppColors.textSecondary)
        }
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
        case .none: return ""
        }
    }

    private var currentIcon: String {
        switch buttonType {
        case .milk: return "bottle.fill"
        case .feeding: return "heart.circle.fill"
        case .sleep: return "moon.stars.fill"
        case .diaper: return "squareshape.fill"
        case .none: return "questionmark"
        }
    }

    private var currentColor: Color {
        switch buttonType {
        case .milk: return AppColors.warning
        case .feeding: return Color(red: 0.9, green: 0.6, blue: 0.8)
        case .sleep: return AppColors.info
        case .diaper: return Color(red: 0.7, green: 0.5, blue: 0.4)
        case .none: return AppColors.textSecondary
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

        case .none:
            break
        }

        isShow = false
    }

    private func saveToStorage(_ record: MilkRecord) {
        // UserDefaults 저장
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(record) {
            UserDefaults.standard.setValue(encoded, forKey: "milkRecord")
        }

        // Firebase 저장
        saveFeedHistory(data: record)

        // PersistenceManager 저장
        PersitenceManager.updateWith(favorite: record, actionType: .add, key: .feed) { error in
            if error != nil {
                DispatchQueue.main.async {
                    print("Error saving record")
                }
            } else {
                DispatchQueue.main.async {
                    print("Record saved successfully")
                }
            }
        }
    }

    private func saveFeedHistory(data: MilkRecord) {
        let user = Auth.auth().currentUser
        if user != nil {
            let groupCode = UserDefaults.standard.string(forKey: "groupCode") ?? "error"
            let locationRef = ref.child(groupCode)

            guard let savedFeedData = UserDefaults.standard.object(forKey: "feed") as? Data else {
                return
            }

            do {
                let decoder = JSONDecoder()
                var feeds = try decoder.decode([MilkRecord].self, from: savedFeedData)
                feeds.append(data)

                let jsonData = try JSONEncoder().encode(feeds)
                let jsonString = String(data: jsonData, encoding: .utf8)
                locationRef.setValue(jsonString)
            } catch {
                print("Encoding error: \(error)")
            }
        }
    }
}

// MARK: - Extensions
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
