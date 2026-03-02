//
//  StaticsView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/01.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct StaticsView: View {
    @Binding var isTableShow: Bool
    @State var milkDatas: [MilkRecord] = []
    @State var milkKeys: [String] = []
    @State var testMilkDatas: [String?: [MilkRecord]] = [:]
    
    private let ref = Database.database().reference(withPath: "feed-history")
    
    
    var body: some View {
        VStack {
            HStack {
                CloseView()
            }
            if milkKeys == [] {
                Text("데이터가 없습니다.")
            }
            List {
                ForEach(milkKeys, id: \.self) { key in
                    Section {
                        
                        ForEach(testMilkDatas[key] ?? [], id: \.self) { item in
                            RecordRowView(item: item)
                        }

                        .onDelete { indexSet in
                            testMilkDatas[key]?.remove(atOffsets: indexSet)
                            PersistenceManager.deleteWith(records: testMilkDatas, actionType: .add, key: .feed) { error in
                                print("todo")
                            }
                            sendDeleteDate(records: testMilkDatas)
                            
                        }
                    } header: {
                        Text(key)
                    }
                    .onAppear {
                        testMilkDatas[key] = testMilkDatas[key]?.sorted(by: {
                            $0.startTime.compare($1.startTime) == .orderedDescending
                        })
                    }
                }
            }
        }
        .padding()
        
        .onAppear {
            // 1. 먼저 로컬 데이터 로드 (즉시 표시)
            loadLocalData()

            // 2. Firebase 로그인 상태면 동기화 시도
            let user = Auth.auth().currentUser
            if let user = user {
                syncWithFirebase()
            }
        }
    }

    // MARK: - Load Local Data
    private func loadLocalData() {
        print("📱 로컬 데이터 로드 중...")
        PersistenceManager.retrieveFavorites(key: .feed) { result in
            switch result {
            case .success(let datas):
                print("✅ 로컬 데이터 로드 성공: \(datas.count)개")
                milkDatas = datas
                testMilkDatas = recordByDay(milkrecords: milkDatas)

                milkKeys = getGroupKeys(milkrecords: milkDatas)
                milkKeys = milkKeys.sorted {$0.compare($1, options: .numeric) == .orderedDescending}
            case .failure(let error):
                print("❌ 로컬 데이터 로드 실패: \(error)")
            }
        }
    }

    // MARK: - Sync with Firebase
    private func syncWithFirebase() {
        print("☁️ Firebase 동기화 시도...")
        let groupCode = UserDefaults.standard.string(forKey: "groupCode") ?? "error"
        let userItemRef = ref.child(groupCode)

        userItemRef.observe(.value, with: { snapShot in
            guard let snapData = snapShot.value as? String else {
                print("⚠️ Firebase 데이터 없음 - 로컬 데이터 사용")
                return
            }

            do {
                guard let jsonData = snapData.data(using: .utf8) else {
                    print("❌ Firebase 데이터 UTF-8 변환 실패")
                    return
                }
                let firebaseData = try JSONDecoder().decode([MilkRecord].self, from: jsonData)
                print("✅ Firebase 데이터 로드 성공: \(firebaseData.count)개")

                // Firebase 데이터를 로컬과 병합
                mergeData(firebaseData: firebaseData)
            } catch {
                print("❌ Firebase 디코딩 오류: \(error)")
                // Firebase 오류 시 로컬 데이터 계속 사용
            }
        })
    }

    // MARK: - Merge Data
    private func mergeData(firebaseData: [MilkRecord]) {
        // Firebase 데이터와 로컬 데이터 병합 (중복 제거)
        var allRecords = milkDatas + firebaseData

        // ID 기반 중복 제거
        var uniqueRecords: [MilkRecord] = []
        var seenIds = Set<UUID>()

        for record in allRecords {
            if !seenIds.contains(record.id) {
                seenIds.insert(record.id)
                uniqueRecords.append(record)
            }
        }

        print("📊 병합된 데이터: 로컬 \(milkDatas.count)개 + Firebase \(firebaseData.count)개 = 총 \(uniqueRecords.count)개")

        milkDatas = uniqueRecords
        testMilkDatas = recordByDay(milkrecords: milkDatas)

        milkKeys = getGroupKeys(milkrecords: milkDatas)
        milkKeys = milkKeys.sorted {$0.compare($1, options: .numeric) == .orderedDescending}

        // 병합된 데이터를 로컬에 저장
        PersistenceManager.save(favorites: milkDatas, key: .feed)
    }

    private func sendDeleteDate(records: [String? : [MilkRecord]]) {
        var tempMilkRecord: [MilkRecord] = []
        
        for element in records {
            element.value.forEach { item in
                tempMilkRecord.append(item)
            }
        }
        
        let user = Auth.auth().currentUser
        if user != nil {
            let groupCode = UserDefaults.standard.string(forKey: "groupCode") ?? "error"
            let locationRef = ref.child(groupCode)
            
           
            
            do {
                let jsonData = try JSONEncoder().encode(tempMilkRecord)
                let jsonString = String(data: jsonData, encoding: .utf8)
                locationRef.setValue(jsonString)
            } catch {
                print("❌ Firebase 데이터 인코딩 실패: \(error)")
            }
        }
    }
    
    @ViewBuilder
    func CloseView() -> some View {
        Spacer()
        Button {
            isTableShow = false
        } label: {
            Image(systemName: "x.square")
                .resizable()
                .frame(width: 30, height: 30)
        }
    }
    
    @ViewBuilder
    func RecordRowView(item: MilkRecord) -> some View {
        HStack {
            if item.milkQuantity != nil {
                Text("\(item.startTime.formatted("HH:mm"))")
                Spacer()
                Text("\(item.milkQuantity?.description ?? "0")ml")
            } else if item.sleepTime != nil {
                Text("\(item.startTime.formatted("HH:mm"))")
                Spacer()
                Text("\(item.sleepTime ?? 0)분")
            } else if item.diaperPee != nil || item.diaperPoo != nil {
                Text("\(item.startTime.formatted("HH:mm"))")
                Spacer()
                VStack {
                    Text("소변: \(item.diaperPee ?? false ? "했음":"안했음") ")
                    Text ("대변: \(item.diaperPoo ?? false ? "했음":"안했음")")
                }
            } else if item.feedingTime != nil {
                Text("\(item.startTime.formatted("HH:mm"))")
                Spacer()
                Text("\(item.feedingTime?.description ?? "0")분")
            }
            
            Spacer()
            if item.milkQuantity != nil {
                Image("feeding bottle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30,
                           height: 30)
                    .padding()
                    .background(.yellow)
                    .cornerRadius(12)
            }
            else if item.sleepTime != nil {
                Image(systemName: "moon.stars.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30 ,
                           height: 30)
                    .padding()
                    .background(.purple)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .yellow)
                    .cornerRadius(12)
            } else if item.diaperPee != nil || item.diaperPoo != nil {
                Image("diaper")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30,
                           height: 30)
                    .padding()
                    .background(.brown)
                    .cornerRadius(12)
            } else if item.feedingTime != nil {
                Image("feeding mother")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30,
                           height: 30)
                    .padding()
                    .background(.blue)
                    .cornerRadius(12)
            }
        }
    }
    
    private func getGroupKeys(milkrecords: [MilkRecord]) -> [String]{
        var keys: [String] = []
        
        let groupedRecords = Dictionary(grouping: milkrecords, by: { $0.startTimeDate })
        groupedRecords.keys.forEach { key in
            keys.append(key ?? "error")
        }
        
        return keys
    }
    
    private func recordByDay(milkrecords: [MilkRecord]) -> [String?: [MilkRecord]] {
        guard !milkrecords.isEmpty else { return [:] }
        
        let groupedRecords = Dictionary(grouping: milkrecords, by: { $0.startTimeDate })
        
        return groupedRecords
    }
}

struct StaticsView_Previews: PreviewProvider {
    static var previews: some View {
        StaticsView(isTableShow: .constant(true),milkKeys: ["2022-01-06"])
    }
}
