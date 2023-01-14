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
    
    @State var profile: Profile?
    
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
    
    var body: some View {
        VStack(spacing: 15) {
            // MARK: Header
            VStack(alignment: .leading, spacing: 5) {
                if let profile {
                    HStack(alignment: .bottom) {
                        Text("\(profile.name)")
                            .font(.largeTitle)
                        
                        Text("태어난 지 \(diff.day?.description ?? "0")일째")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                    }
                    
                } else {
                    /// - 프로필이 생성되지 않은 경우, 입력을 유도하는 메세지 삽입
                    Text("아기의 이름과 태어난 날을 입력해주세요.")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .setHorizontalAlign(.leading)
            
            /// - 스크롤 되더라도 헤더는 올라가지 않도록 View 분리
            // MARK: Button Grid
            // ???: 아이템이 더 추가될 계획이라서 ScrollView일까요?
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
                        
                        Button {
                            buttonType = .feeding
                            isShow.toggle()
                        } label: {
                            Image("feeding mother")
                                .resizable()
                                .modifier(CustomButtonLabel(backgroundColor: .purple, strokeColor: .yellow))
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
                        
                        Button {
                            isBathTimerShow.toggle()
                        } label: {
                            Image("bath")
                                .resizable()
                                .modifier(CustomButtonLabel(backgroundColor: .blue, strokeColor: .indigo))
                        }
                    }
                    
                    GridRow {
                        Button {
                            buttonType = .sleep
                            isShow.toggle()
                        } label: {
                            Image(systemName: "moon.stars.fill")
                                .resizable()
                                .foregroundColor(.yellow)
                                .modifier(CustomButtonLabel(backgroundColor: .teal, strokeColor: .orange))
                        }
                        
                        Button {
                            isTableShow.toggle()
                        } label: {
                            Image(systemName: "list.bullet.clipboard")
                                .resizable()
                                .foregroundColor(.white)
                                .modifier(CustomButtonLabel(backgroundColor: .green, strokeColor: .pink))
                        }
                    }
                }
            }
            /// - 버튼 혹은 HStack에 무분별하게 달려있던 sheet 메서드를 제거하고 ScrollView에만 적용
            /// - sheet는 내부의 Picker를 조작하다가 실수로 닫을 가능성이 크므로 fullScreenCover로 변경
            .fullScreenCover(isPresented: $isShow) {
                /// - View 내부의 NavigationTitle 및 Toolbar button을 위해 NavigationStack 사용
                NavigationStack{
                    switch buttonType {
                    case .milk:
                        BottleFeedingView()
                    case .feeding:
                        BreastFeedingView()
                    case .diaper:
                        DiaperView()
                    case .sleep:
                        SleepingRecordView()
                    default:
                        Text("Error")
                    }
                }
            }
            .fullScreenCover(isPresented: $isBathTimerShow) {
                BathTimerView(isBathTimerShow: $isBathTimerShow)
            }
            .fullScreenCover(isPresented: $isTableShow) {
                StaticsView(isTableShow: $isTableShow)
            }
            .fullScreenCover(isPresented: $isEnterProfile, onDismiss: {
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
            }
        }
        .padding()
        
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
        ContentView(profile: Profile(name: "아키", birthDate: Date()), buttonType: .milk)
    }
}
