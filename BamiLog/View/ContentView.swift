//
//  ContentView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/01.
//

import SwiftUI

enum ButtonType {
    case milk
    case sleep
    case diaper
    case feeding
}

struct ContentView: View {
    
    @State var profile: Profile?
    
    /// - 뷰 내부에 정의된 상수를 연산 프로퍼티로 처리
    var diff: DateComponents {
        Calendar.current.dateComponents([.day], from: profile?.birthDate ?? Date() , to: Date())
    }
    
    // MARK: View Properties
    @State var isShow: Bool = false
    @State var isTableShow: Bool = false
    @State var isEnterProfile: Bool = false
    @State var isBathTimerShow: Bool = false
    @State var buttonType: ButtonType?
    private let cellWidth = UIScreen.screenWidth/2 - 30
    var body: some View {
        VStack {
            // MARK: Header
            VStack(alignment: .leading, spacing: 5) {
                if let profile {
                    /// - 조금 더 감성을 자극하는 문구로 변경
                    (Text("\(profile.name)")
                        .font(.title)
                     
                     + Text("(이)는 오늘...")
                        .font(.title3)
                        .foregroundColor(.gray)
                     )
                    
                    (Text("태어난 지 ")
                     +
                     Text("\(diff.day?.description ?? "0")일")
                        .foregroundColor(.orange)
                     +
                     Text(" 됐어요.")
                    )
                    .foregroundColor(.gray)
                    .font(.title)
                } else {
                    /// - 프로필이 생성되지 않은 경우, 입력을 유도하는 메세지 삽입
                    Text("아기의 이름과 태어난 날을 입력해주세요.")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .hAlign(.leading)
            
            // ???: 아이템이 더 추가될 계획이라서 ScrollView일까요?
            /// - 스크롤 되더라도 헤더는 올라가지 않도록 View 분리
            ScrollView(showsIndicators: false) {
                HStack(spacing: 20) {
                    Button {
                        buttonType = .milk
                        isShow = true
                    } label: {
                        Image("feeding bottle")
                            .resizable()
                            .modifier(CustomButtonLabel(backgroundColor: .yellow, strokeColor: .blue))
                    }
                    
                    Button {
                        buttonType = .sleep
                        isShow = true
                    } label: {
                        Image(systemName: "moon.stars.fill")
                            .resizable()
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .yellow)
                            .modifier(CustomButtonLabel(backgroundColor: .purple, strokeColor: .yellow))
                    }
                }
                .padding()
                
                HStack(spacing: 20) {
                    Button {
                        buttonType = .diaper
                        isShow = true
                    } label: {
                        Image("diaper")
                            .resizable()
                            .modifier(CustomButtonLabel(backgroundColor: .brown, strokeColor: .pink))
                    }
                    
                    Button {
                        buttonType = .feeding
                        isShow = true
                    } label: {
                        Image("feeding mother")
                            .resizable()
                            .modifier(CustomButtonLabel(backgroundColor: .blue, strokeColor: .indigo))
                    }
                }
                
                HStack(spacing: 20) {
                    Button {
                        isBathTimerShow = true
                    } label: {
                        Image("bath")
                            .resizable()
                            .modifier(CustomButtonLabel(backgroundColor: .green, strokeColor: .pink))
                    }
                    
                    Button {
                        isTableShow = true
                    } label: {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .resizable()
                            .foregroundColor(.black)
                            .modifier(CustomButtonLabel(backgroundColor: .teal, strokeColor: .orange))
                    }
                }
                .padding()
            }
            .sheet(isPresented: $isShow) {
                RecordView(buttonType: $buttonType, isShow: $isShow)
            }
            .sheet(isPresented: $isBathTimerShow) {
                BathTimerView(isBathTimerShow: $isBathTimerShow)
            }
            .sheet(isPresented: $isTableShow) {
                StaticsView(isTableShow: $isTableShow)
            }
            .sheet(isPresented: $isEnterProfile, onDismiss: {
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
        let strokeColor: Color
        
        func body(content: Content) -> some View {
            content
                .scaledToFit()
                .padding()
                .frame(width: cellWidth, height: cellWidth)
                .background(backgroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(strokeColor, lineWidth: 8)
                )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(profile: Profile(name: "테스트", birthDate: Date()), buttonType: .milk)
    }
}

extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
