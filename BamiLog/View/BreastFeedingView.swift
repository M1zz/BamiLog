//
//  BreastFeedingView.swift
//  BamiLog
//
//  Created by Roen White on 2023/01/14.
//

import SwiftUI

struct BreastFeedingView: View {
    // MARK: View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var recordTime = Date()
    @State private var feedingTime: Int = 5
    
    var body: some View {
        VStack {
            Form {
                Section("직수 시간") {
                    Picker("먹인 시간", selection: $feedingTime) {
                        ForEach(1...70, id: \.self) { number in
                            Text("\(number)분")
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 190)
                }
                
                Section("수유 종료 시각") {
                    DatePicker("",
                               selection: $recordTime)
                    .datePickerStyle(WheelDatePickerStyle())
                    .frame(height: 190)
                }
            }
        }
        .navigationTitle("모유 수유 기록하기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            /// - 왼쪽 위 닫기 버튼
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .contentShape(Rectangle())
                }
            }
            /// - 오른쪽 위 저장 버튼
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let feedingRecord = MilkRecord(startTime: recordTime,
                                                  startTimeDate: recordTime.formatted("yyyy-MM-dd"),
                                                  feedingTime: feedingTime)
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(feedingRecord) {
                        UserDefaults.standard.setValue(encoded, forKey: "milkRecord")
                    }
                    
                    PersitenceManager.updateWith(favorite: feedingRecord, actionType: .add, key: .feed) { error in
                        guard error != nil else {
                            DispatchQueue.main.async {
                                print("OK!")
                            }
                            return
                        }
                        
                        DispatchQueue.main.async {
                            //self.presentGFAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
                            print("Error")
                        }
                    }
                    
                    dismiss()
                    
                    print("\(String(describing: recordTime)) \(String(describing: feedingTime)) 저장되었습니다.")
                } label: {
                    Text("저장")
                }
            }
        }
    }
}

struct BreastFeedingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BreastFeedingView()
        }
    }
}
