//
//  ContentView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/01.
//

import SwiftUI

enum ButtonType {
    case milk
    case feeding
    case diaper
    case sleep
}

struct ContentView: View {
    
    @State var profile: BabyInfomation?
    
    /// - View 내부에 정의된 상수를 연산 프로퍼티로 변경
    var diff: DateComponents {
        Calendar.current.dateComponents([.day], from: profile?.birthDate ?? Date() , to: Date())
    }
    
    // MARK: View Properties
    @State var isShow: Bool = false
    @State var isTableShow: Bool = false
    @State var isEnterProfile: Bool = false
    @State var isBathTimerShow: Bool = false
    @State var buttonType: ButtonType?
    
    @State var showLoginPage: Bool = false
    @AppStorage("loginStatus") var loginStatus = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                // MARK: Header
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        profileView()
                        Spacer()
                        NavigationLink {
                            CoworkView(showLoginPage: $showLoginPage)
                        } label: {
                            Image(systemName: "person.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }


                    }
                }
                .setHorizontalAlign(.leading)
                
                /// - 스크롤 되더라도 헤더는 올라가지 않도록 View 분리
                // MARK: Button Grid
                ScrollView(showsIndicators: false) {
                    /// - 기록할 종류에 맞게 버튼위치 조정
                    /// - 1행 수유기록, 2행 청결관련, 3행 수면 및 기록확인
                    Grid(horizontalSpacing: 25, verticalSpacing: 25) {
                        GridRow {
                            Button {
                                buttonType = .milk
                                isShow.toggle()
                            } label: {
                                Image("feeding bottle")
                                    .resizable()
                                    .modifier(CustomButtonLabel(backgroundColor: .yellow, strokeColor: .blue ))
                                
                            }
                            .sheet(isPresented: $isShow) {
                                RecordView(buttonType: $buttonType, isShow: $isShow)
                            }
                            
                            Button {
                                buttonType = .feeding
                                isShow.toggle()
                            } label: {
                                Image("feeding mother")
                                    .resizable()
                                    .modifier(CustomButtonLabel(backgroundColor: .purple, strokeColor: .yellow))
                            }
                            .sheet(isPresented: $isShow) {
                                RecordView(buttonType: $buttonType, isShow: $isShow)
                            }
                        }
                        
                        GridRow {
                            Button {
                                buttonType = .diaper
                                isShow.toggle()
                            } label: {
                                Image("diaper")
                                    .resizable()
                                    .modifier(CustomButtonLabel(backgroundColor: .brown, strokeColor: .pink))
                            }
                            .sheet(isPresented: $isShow) {
                                RecordView(buttonType: $buttonType, isShow: $isShow)
                            }
                            
                            Button {
                                isBathTimerShow.toggle()
                            } label: {
                                Image("bath")
                                    .resizable()
                                    .modifier(CustomButtonLabel(backgroundColor: .blue, strokeColor: .indigo))
                            }
                            .sheet(isPresented: $isBathTimerShow) {
                                BathTimerView(isBathTimerShow: $isBathTimerShow)
                            }
                        }
                        
                        GridRow {
                            Button {
                                buttonType = .sleep
                                isShow.toggle()
                            } label: {
                                Image("sleep")
                                    .resizable()
                                    .foregroundColor(.yellow)
                                    .modifier(CustomButtonLabel(backgroundColor: .teal, strokeColor: .orange))
                            }
                            .sheet(isPresented: $isShow) {
                                RecordView(buttonType: $buttonType, isShow: $isShow)
                            }
                            
                            Button {
                                isTableShow.toggle()
                            } label: {
                                Image("history")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .modifier(CustomButtonLabel(backgroundColor: .green, strokeColor: .pink))
                            }
                            .sheet(isPresented: $isTableShow) {
                                StaticsView(isTableShow: $isTableShow)
                            }
                        }
                    }
                }
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
                                profile = babyProfile
                            case .failure(_):
                                DispatchQueue.main.async {
                                    isEnterProfile = true
                                    print("Error profile")
                                }
                            }
                        }
                    }
                    
                    loginStatus = UserDefaults.standard.bool(forKey: "loginStatus")
                }
            }
            .padding()
        }
        
        
    }
    
    @ViewBuilder
    private func profileView() -> some View {
        if let profile {
            VStack {
                HStack(alignment: .bottom) {
                    Text("\(profile.name)")
                        .font(.largeTitle)
                    
                    Text("태어난 지 \(diff.day?.description ?? "0")일째")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(.bottom, 2)
                    Spacer()
                }
                HStack {
                    Text("기적의 100일까지 \((100 - (diff.day ?? 0)).description )일")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            
        } else {
            /// - 프로필이 생성되지 않은 경우, 입력을 유도하는 메세지 삽입
            Text("아기의 이름과 태어난 날을 입력해주세요.")
                .font(.title2)
                .foregroundColor(.gray)
        }
    }
    
    // MARK: 버튼의 모양이 전부 똑같아서 다른 것들(배경색, 테두리색)만 받도록 커스텀 수정자를 작성
    struct CustomButtonLabel: ViewModifier {
        private let cellWidth = UIScreen.screenWidth/2 - 30
        let backgroundColor: Color
        var strokeColor: Color = .clear
        
        func body(content: Content) -> some View {
            content
                .scaledToFit()
                .padding()
                .frame(width: cellWidth, height: cellWidth)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(strokeColor, lineWidth: 12)
                )
                .cornerRadius(12)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(profile: BabyInfomation(name: "아키", birthDate: Date()), buttonType: .milk, showLoginPage: false)
    }
}
