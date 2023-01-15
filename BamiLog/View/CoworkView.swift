//
//  CoworkView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/14.
//

import SwiftUI
import FirebaseAuth

#warning("name이 맞는가? -> 키와 밸류")
struct Profile: Identifiable {
    var id: UUID = UUID()
    let name: String
    var value: String
    let detailType: DetailType
}

enum DetailType {
    case login
    case group
    case qrGenerator
}

struct CoworkView: View {
    
    
    @AppStorage("loginStatus") var loginStatus = false
    @Binding var showLoginPage: Bool
    @State private var userName: String = ""
    @State var arrayData = [Profile(name: "참가중인 그룹 코드", value: "", detailType: .group),
                            Profile(name: "로그인 된 ID", value: "", detailType: .login),
    ]
    
    @State var showQRScanView: Bool = false
    @State var showQRGeneratorView: Bool = false
    
    @State var needPresentGroupCode: Bool = false
    
    @State var showingAlert: Bool = false
    var body: some View {
        VStack {
            Spacer()
            Button {
                showQRScanView.toggle()
            } label: {
                Text("QR 코드 스캔")
                    .font(.system(size: 30))
                    .bold()
                    .tint(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(.green)
                    .cornerRadius(14)
            }
            .padding()
            Button {
                showQRGeneratorView.toggle()
            } label: {
                Text("QR 코드 생성")
                    .font(.system(size: 30))
                    .bold()
                    .tint(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(.blue)
                    .cornerRadius(14)
            }
            .padding()
            Spacer()
            
            if loginStatus {
                Button {
                    showingAlert.toggle()
                    
                    
                } label: {
                    Text("로그아웃")
                    
                }
                .alert("로그아웃 되었습니다.", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) {
                        loginStatus = false
                        UserDefaults.standard.set(false,
                                                  forKey: "loginStatus")
                    }
                }
                .padding()
                Button {
                    showingAlert.toggle()
                    
                    
                } label: {
                    Text("회원탈퇴")
                    
                }
                .alert("회원탈퇴 되었습니다.", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) {
                        loginStatus = false
                        UserDefaults.standard.set(false,
                                                  forKey: "loginStatus")
                    }
                }
                .padding()
            }

        }
        .padding()
        .sheet(isPresented: $showQRScanView, content: {
            QRCodeScanView(needPresentGroupCode: $needPresentGroupCode, userGroupCode: "")
        })
        .sheet(isPresented: $showQRGeneratorView, content: {
            QRGeneratorView()
        })
        .onAppear(perform: {
            
            showLoginPage = !loginStatus
            if userName == "" {
                let randomUserName = getTempRandomUsername()
                if let tempUserName = UserDefaults.standard.string(forKey: "userName") {
                    userName = tempUserName
                } else {
                    UserDefaults.standard.set(randomUserName,
                                              forKey: "userName")
                    userName = randomUserName
                }
            } else {
                userName = UserDefaults.standard.string(forKey: "userName") ?? "이현호"
            }
            
            if arrayData.first?.value == "" {
                if let loginStatus = UserDefaults.standard.string(forKey: "groupCode") {
                    arrayData[0].value = loginStatus
                } else {
                    arrayData[0].value = "미참가"
                }
            }
            
            if arrayData[1].value == "" {
                let user = Auth.auth().currentUser
                if let user = user {
                    arrayData[1].value = user.email ?? "error"
                }
            }
            
            if UserDefaults.standard.string(forKey: "groupCode") == nil {
                UserDefaults.standard.set(randomString(length: 6).uppercased(),
                                          forKey: "groupCode")
            }
        })
        .sheet(isPresented: $showLoginPage,
               onDismiss: {
            if loginStatus {
                showLoginPage = false
            } else {
                showLoginPage = true
            }
            
#warning("로그인 없이 코드 돌리기 위한 코드")
        }) {
            if !loginStatus {
                LoginView(showLoginPage: $showLoginPage)
            }
        }
    }
    
    private func getTempRandomUsername() -> String {
        let animalNames = ["기린", "코끼리", "사자", "팬더", "고라니"]
        let randomNumber = Int.random(in: 0...999)
        return "\(animalNames.randomElement() ?? "비둘기")\(randomNumber)"
    }
    
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

struct CoworkView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        CoworkView(loginStatus: true,
                   showLoginPage: .constant(false))
    }
}
