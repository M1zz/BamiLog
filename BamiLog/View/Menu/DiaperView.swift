//
//  DiaperView.swift
//  BamiLog
//
//  Created by Roen White on 2023/01/14.
//

import SwiftUI

struct DiaperView: View {
    // MARK: View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var recordTime = Date()
    @State private var diaperPee: Bool = false
    @State private var diaperPoo: Bool = false
    
    var body: some View {
        VStack {
            Form {
                Section("대소변 기록") {
                    Toggle("쉬", isOn: $diaperPee)
                    Toggle("응가", isOn: $diaperPoo)
                }
                
                Section("기저귀 확인 시각") {
                    DatePicker("",
                               selection: $recordTime)
                    .datePickerStyle(WheelDatePickerStyle())
                    .frame(height: 190)
                }
            }
        }
        .navigationTitle("배변 기록하기")
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
                    let diaperRecord = MilkRecord(startTime: recordTime,
                                                  startTimeDate: recordTime.formatted("yyyy-MM-dd"),
                                                 diaperPee: diaperPee,
                                                 diaperPoo: diaperPoo)
                    
                    let encoder = JSONEncoder()
                    
                    if let encoded = try? encoder.encode(diaperRecord) {
                        UserDefaults.standard.setValue(encoded, forKey: "milkRecord")
                    }
                    
                    PersitenceManager.updateWith(favorite: diaperRecord, actionType: .add, key: .feed) { error in
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
                    
                    print("\(String(describing: diaperPee)) \(String(describing: diaperPoo)) 저장되었습니다.")
                } label: {
                    Text("저장")
                }
            }
        }
    }
}

struct DiaperView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiaperView()
        }
    }
}
