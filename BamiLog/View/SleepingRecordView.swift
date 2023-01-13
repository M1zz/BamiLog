//
//  SleepingRecordView.swift
//  BamiLog
//
//  Created by Roen White on 2023/01/14.
//

import SwiftUI

struct SleepingRecordView: View {
    // MARK: View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var recordTime = Date()
    @State private var sleepTime: Int = 30
    
    var body: some View {
        VStack {
            Form {
                Section("총 수면 시간") {
                    Picker("잔 시간", selection: $sleepTime) {
                        ForEach(1...30, id: \.self) { number in
                            Text("\(number*5)분")
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 190)
                }
                
                Section("잠든 시각") {
                    DatePicker("",
                               selection: $recordTime)
                    .datePickerStyle(.wheel)
                    .frame(height: 190)
                }
            }
        }
        .navigationTitle("수면 기록하기")
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
                    let sleepRecord = MilkRecord(startTime: recordTime,
                                                 startTimeDate: recordTime.formatted("yyyy-MM-dd"),
                                                 sleepTime: sleepTime)
                    
                    let encoder = JSONEncoder()
                    
                    if let encoded = try? encoder.encode(sleepRecord) {
                        UserDefaults.standard.setValue(encoded, forKey: "milkRecord")
                    }
                    
                    PersitenceManager.updateWith(favorite: sleepRecord, actionType: .add, key: .feed) { error in
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
                    
                    print("\(recordTime) \(sleepTime) 저장되었습니다.")
                } label: {
                    Text("저장")
                }
            }
        }
    }
}

struct SleepingRecordView_Previews: PreviewProvider {
    static var previews: some View {
        SleepingRecordView()
    }
}
