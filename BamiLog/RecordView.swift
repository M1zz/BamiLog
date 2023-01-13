//
//  RecordView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/01.
//

import SwiftUI

// 1. 홈 화면 이쁘게 꾸미기
// 2. 저장하면 뷰 사라지기

struct RecordView: View {
    @Binding var buttonType: ButtonType?
    @Binding var isShow: Bool
    @State private var recordTime = Date()
    @State private var quantity: Int = 5
    @State private var milkType: MilkType = .natural
    @State private var feedingTime: Int = 5
    
    @State private var sleepTime: Int = 30
    
    //@State private var recordStopTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    
    @State private var diaperPee: Bool? = false
    @State private var diaperPoo: Bool? = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    isShow = false
                } label: {
                    Image(systemName: "x.square")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
            }
            switch buttonType {
            case .milk:
                Picker("종류", selection: $milkType) {
                    Text("모유")
                        .tag(MilkType.natural)
                    Text("분유")
                        .tag(MilkType.powder)
                }.pickerStyle(.segmented)
                HStack {
                    Text("먹인양")
                    Picker("먹인 양", selection: $quantity) {
                        ForEach(1...30, id: \.self) { number in
                            Text("\(number*10)ml")
                        }
                    }
                    .pickerStyle(.wheel)
                }
                Text("먹은 시간을 선택해주세요")
                DatePicker("",
                           selection: $recordTime)
                .datePickerStyle(WheelDatePickerStyle())
                Spacer()
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
                    isShow = false
                    print("\(recordTime) \(quantity) 저장되었습니다.")
                } label: {
                    Text("저장하기")
                        .bold()
                        .font(.system(.title2))
                        .foregroundColor(.white)
                        .frame(width: UIScreen.screenWidth-20, height: 40)
                        .background(.green)
                        .cornerRadius(12)
                        .padding()
                }
                .buttonStyle(.plain)
                
            case .sleep:
                
                
                
                Text("얼마나 잤나요?")
                
                
                Picker("잔 시간", selection: $sleepTime) {
                    ForEach(1...30, id: \.self) { number in
                        Text("\(number*5)분")
                    }
                }
                .pickerStyle(.wheel)
                
                Text("잠든 시간를 선택해주세요")
                DatePicker("",
                           selection: $recordTime)
                .datePickerStyle(WheelDatePickerStyle())
                
                Spacer()
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
                    isShow = false
                    print("\(recordTime) \(sleepTime) 저장되었습니다.")
                } label: {
                    Text("저장하기")
                        .bold()
                        .font(.system(.title2))
                        .foregroundColor(.white)
                        .frame(width: UIScreen.screenWidth-20, height: 50)
                        .background(.green)
                        .cornerRadius(12)
                        .padding()
                }
                .buttonStyle(.plain)
            
            case .diaper:
                
                HStack {
                    Button {
                        diaperPee?.toggle()
                    } label: {
                        if diaperPee ?? false {
                            Text("소변했음")
                            .frame(width: 100, height: 100)
                            .background(.green)
                            .cornerRadius(12)
                        } else {
                            Text("소변안했음")
                                .frame(width: 100, height: 100)
                                .background(.red)
                                .cornerRadius(12)
                        }
                    }.buttonStyle(.plain)

                    Button {
                        diaperPoo?.toggle()
                    } label: {
                        if diaperPoo ?? false {
                            Text("대변했음")
                            .frame(width: 100, height: 100)
                            .background(.green)
                            .cornerRadius(12)
                        } else {
                            Text("대변안했음")
                                .frame(width: 100, height: 100)
                                .background(.red)
                                .cornerRadius(12)
                        }
                    }.buttonStyle(.plain)
                }
                .padding()
                
                Text("시간를 선택해주세요") // 오타있어요
                DatePicker("",
                           selection: $recordTime)
                .datePickerStyle(WheelDatePickerStyle())
                Spacer()
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
                    isShow = false
                    print("\(String(describing: diaperPee)) \(String(describing: diaperPoo)) 저장되었습니다.")
                } label: {
                    Text("저장하기")
                        .bold()
                        .font(.system(.title2))
                        .foregroundColor(.white)
                        .frame(width: UIScreen.screenWidth-20, height: 50)
                        .background(.green)
                        .cornerRadius(12)
                        .padding()
                }
                .buttonStyle(.plain)
            case .feeding:
                Text("총 수유 시간")
                Picker("먹인 시간", selection: $feedingTime) {
                    ForEach(1...70, id: \.self) { number in
                        Text("\(number)분")
                    }
                }
                .pickerStyle(.wheel)
                
                Text("시간를 선택해주세요")
                DatePicker("",
                           selection: $recordTime)
                .datePickerStyle(WheelDatePickerStyle())
                Spacer()
                Button {
                    let diaperRecord = MilkRecord(startTime: recordTime,
                                                  startTimeDate: recordTime.formatted("yyyy-MM-dd"),
                                                  feedingTime: feedingTime)
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
                    isShow = false
                    print("\(String(describing: diaperPee)) \(String(describing: diaperPoo)) 저장되었습니다.")
                } label: {
                    Text("저장하기")
                        .bold()
                        .font(.system(.title2))
                        .foregroundColor(.white)
                        .frame(width: UIScreen.screenWidth-20, height: 50)
                        .background(.green)
                        .cornerRadius(12)
                        .padding()
                }
                .buttonStyle(.plain)
            default:
                Text("error")
            }
        }
        .padding()
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(buttonType: .constant(.feeding), isShow: .constant(true))
    }
}

extension Date {

    public func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)!
        
        return formatter.string(from: self)
    }
}
