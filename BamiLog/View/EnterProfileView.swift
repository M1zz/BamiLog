//
//  EnterProfileView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/01.
//

import SwiftUI

struct EnterProfileView: View {
    @State var name: String = ""
    @State var birthDate: Date = Date()
    @Binding var isEnterProfile: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    isEnterProfile = false
                } label: {
                    Image(systemName: "x.square")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
            }
            TextField("이름이 뭐에요?", text: $name)
                .textFieldStyle(.roundedBorder)
                
            DatePicker(selection: $birthDate, in: ...Date(),
                       displayedComponents: .date) {
                            Text("생일이 언제에요?")
                        }
            Button {
                let profile = BabyInfomation(name: name, birthDate: birthDate)
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(profile) {
                    UserDefaults.standard.setValue(encoded, forKey: "profile")
                }
                
//                if PersitenceManager.saveProfile(profile: profile, key: .profile) != nil {
//                    print("\(name) \(birthDate) 저장되었습니다.")
//                } else {
//                    print("error 남")
//                }
                isEnterProfile = false
                
            } label: {
                Text("저장하기")
                    .frame(width: UIScreen.screenWidth-20, height: 40)
                    .background(.green)
                    .cornerRadius(12)
                    .padding()
            }
        }
        .padding()
    }
}

struct EnterProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EnterProfileView(name: "바미", birthDate: Date(), isEnterProfile: .constant(true))
    }
}
