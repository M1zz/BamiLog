//
//  BottleFeedingView.swift
//  BamiLog
//
//  Created by Roen White on 2023/01/14.
//

import SwiftUI

struct BottleFeedingView: View {
    // MARK: View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var recordTime = Date()
    @State private var quantity: Int = 5
    @State private var milkType: MilkType = .natural
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("종류")) {
                    Picker("종류", selection: $milkType) {
                        Text("모유")
                            .tag(MilkType.natural)
                        Text("분유")
                            .tag(MilkType.powder)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("먹인 양")) {
                    Picker("먹인 양", selection: $quantity) {
                        ForEach(1...30, id: \.self) { number in
                            Text("\(number * 10)ml")
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 190)
                }
                
                Section("먹인 시각") {
                    DatePicker("",
                               selection: $recordTime)
                    .datePickerStyle(WheelDatePickerStyle())
                    .frame(height: 190)
                }
            }
        }
        .navigationTitle("젖병 수유 기록하기")
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
                    let milkRecord = MilkRecord(startTime: recordTime,
                                                startTimeDate: recordTime.formatted("yyyy-MM-dd"),
                                                milkQuantity: quantity*10)
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(milkRecord) {
                        UserDefaults.standard.setValue(encoded, forKey: "milkRecord")
                    }
                    
                    PersitenceManager.updateWith(favorite: milkRecord, actionType: .add, key: .feed) { error in
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
                    
                    print("\(recordTime) \(quantity) 저장되었습니다.")
                } label: {
                    Text("저장")
                }
            }
        }
    }
}

struct BottleFeedingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BottleFeedingView()
        }
    }
}
