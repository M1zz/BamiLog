//
//  ContentView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/01.
//

import SwiftUI

struct MilkRecord: Codable, Hashable, Identifiable {
    var id = UUID()
    let startTime: Date
    var startTimeDate: String? = nil
    
    var milkType: MilkType? = nil
    var milkQuantity: Int? = nil
    
    var sleepTime: Int? = nil
    
    var diaperPee: Bool? = nil
    var diaperPoo: Bool? = nil
    
    var feedingTime: Int? = nil
}

enum MilkType: Codable {
    case powder
    case natural
}

struct Profile: Codable, Hashable {
    let name: String
    let birthDate: Date
}

enum ButtonType {
    case milk
    case sleep
    case diaper
    case feeding
}

struct ContentView: View {
    
    @State var isShow: Bool = false
    @State var isTableShow: Bool = false
    @State var isEnterProfile: Bool = false
    @State var buttonType: ButtonType?
    private let cellWidth = UIScreen.screenWidth/2 - 30
    @State var profile: Profile?
    
    var body: some View {
        VStack {
            VStack {
                let diff = Calendar.current.dateComponents([.day], from:profile?.birthDate ?? Date() , to: Date())
                Text("\(profile?.name ?? "이름이 뭐에요?")")
                    .bold()
                    .font(.system(.title2))
                Text("D+\(diff.day?.description ?? "")")
                    .bold()
                    .font(.system(size: 45))
            }
            
            HStack(spacing: 20) {
                Button {
                    buttonType = .milk
                    isShow = true
                } label: {
                    Image("feeding bottle")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding()
                        .frame(width: cellWidth ,
                               height: cellWidth)
                        .background(.yellow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 8)
                        )
                }
                .sheet(isPresented: $isShow) {
                    RecordView(buttonType: $buttonType, isShow: $isShow)
                }
                
                
                Button {
                    buttonType = .sleep
                    isShow = true
                } label: {
                    Image(systemName: "moon.stars.fill")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding()
                        .frame(width: cellWidth ,
                               height: cellWidth)
                        .background(.purple)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .yellow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(Color.yellow, lineWidth: 8)
                        )
                }.buttonStyle(.plain)
            }
            .sheet(isPresented: $isShow) {
                RecordView(buttonType: $buttonType, isShow: $isShow)
            }
            .padding()
            
            HStack(spacing: 20) {
                Button {
                    buttonType = .diaper
                    isShow = true
                } label: {
                    Image("diaper")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: cellWidth,
                               height: cellWidth)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.black)
                        .background(.brown)
                        .cornerRadius(12)
                        .tint(.indigo)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(.pink, lineWidth: 8)
                        )
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $isShow) {
                    RecordView(buttonType: $buttonType, isShow: $isShow)
                }
                
                Button {
                    buttonType = .feeding
                    isShow = true
                } label: {
                    Image("feeding mother")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: cellWidth,
                               height: cellWidth)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.black)
                        .background(.blue)
                        .cornerRadius(12)
                        .tint(.indigo)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(.indigo, lineWidth: 8)
                        )
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $isShow) {
                    RecordView(buttonType: $buttonType, isShow: $isShow)
                }
            }
            
            Button {
                isTableShow = true
            } label: {
                Image(systemName: "chart.bar.doc.horizontal")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(width: cellWidth*2 + 20,
                    //.frame(width: cellWidth,
                           height: cellWidth)
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(.black)
                    .background(.teal)
                    .cornerRadius(12)
                    .tint(.indigo)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12).stroke(.orange, lineWidth: 8)
                    )
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $isTableShow) {
                StaticsView(isTableShow: $isTableShow)
            }
            .padding()
        }
        .padding()
        
        .sheet(isPresented: $isEnterProfile, onDismiss: {
            if (profile?.name.isEmpty) == nil {
                PersitenceManager.retrieveProfile(key: .profile) { result in
                    switch result {
                    case .success(let babyProfile):
                        //self.updateUI(with: favorites)
                        profile = babyProfile
                    case .failure(_):
                        DispatchQueue.main.async {
                            //self.presentGFAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
                            isEnterProfile = true
                            print("Error profile")
                        }
                    }
                }
            }
        }, content: {
            EnterProfileView(isEnterProfile: $isEnterProfile)
        })
        .onAppear {
            if (profile?.name.isEmpty) == nil {
                PersitenceManager.retrieveProfile(key: .profile) { result in
                    switch result {
                    case .success(let babyProfile):
                        //self.updateUI(with: favorites)
                        profile = babyProfile
                    case .failure(_):
                        DispatchQueue.main.async {
                            //self.presentGFAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
                            isEnterProfile = true
                            print("Error profile")
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(buttonType: .milk, profile: Profile(name: "테스트", birthDate: Date()))
    }
}

extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
