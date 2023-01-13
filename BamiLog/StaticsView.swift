//
//  StaticsView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/01.
//

import SwiftUI

struct StaticsView: View {
    @Binding var isTableShow: Bool
    @State var milkDatas: [MilkRecord] = []
    @State var milkKeys: [String] = []
    @State var testMilkDatas: [String?: [MilkRecord]] = [:]
    
    var body: some View {
        VStack {
            HStack {
                
                CloseView()
            }
            List {
                ForEach(milkKeys, id: \.self) { key in
                    Section {
                        ForEach(testMilkDatas[key]!, id: \.self) { item in
                            RecordRowView(item: item)
                        }
                        .onDelete { indexSet in
                            //print(testMilkDatas.count)
                            testMilkDatas[key]!.remove(atOffsets: indexSet)
                            PersitenceManager.deleteWith(records: testMilkDatas, actionType: .add, key: .feed) { error in
                                print("todo")
                            }
                            //print(testMilkDatas)
                        }
                    } header: {
                        Text(key)
                    }
                }
                
//                    PersitenceManager.deleteWith(favorite: milkDatas, actionType: .add, key: .feed) { error in
//
//                        guard error != nil else {
//                            DispatchQueue.main.async {
//                                print("OK!")
//                            }
//
//                            return
//                        }
//
//                        DispatchQueue.main.async {
//                            //self.presentGFAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
//                            print("Error")
//                        }
//                    }
                
            }
        }
        .padding()
        
        .onAppear {
            PersitenceManager.retrieveFavorites(key: .feed) { result in
                switch result {
                case .success(let datas):
                    milkDatas = datas
                    testMilkDatas = recordByDay(milkrecords: milkDatas)
                    
                    milkKeys = getGroupKeys(milkrecords: milkDatas)
                    milkKeys = milkKeys.sorted {$0.compare($1, options: .numeric) == .orderedDescending}
                case .failure(_):
                    DispatchQueue.main.async {
                        print("Error")
                    }
                }
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
