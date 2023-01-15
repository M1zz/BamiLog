//
//  LoginView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/14.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @AppStorage("loginStatus") var loginStatus = false
    @StateObject var loginData = LoginViewModel()
    @Binding var showLoginPage: Bool
    
    var body: some View {
        ZStack {
            Image("bg")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width)
                .overlay(Color.black.opacity(0.35))
                .ignoresSafeArea()
                .opacity(0.4)
            
            VStack(spacing: 25){
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 30, content: {
                    Text("공동육아에 참여해 주세요")
                        .font(.system(size: 45))
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                    
                    Text("로그인을 해야 공동육아에 참여할 수 있습니다. 로그인을 완료해서 함께 아이를 키워보아요!")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                })
                .padding(.horizontal,30)
                
                Spacer()

                SignInWithAppleButton { (request) in
                    
                    loginData.nonce = randomNonceString()
                    request.requestedScopes = [.email,.fullName]
                    request.nonce = loginData.nonce.sha256()
                    
                } onCompletion: { (result) in
                    

                    switch result {
                    case .success(let user):
                        guard let credential = user.credential as? ASAuthorizationAppleIDCredential else{
                            print("error with firebase")
                            return
                        }
                        loginData.authenticate(credential: credential)
                        loginStatus = true
                        showLoginPage = false
                    case.failure(let error):
                        print(error.localizedDescription)
                    }
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 55)
                .clipShape(Capsule())
                .padding(.horizontal,40)
                .offset(y: -70)
            }
        }
        .onDisappear {
            if !loginData.loginStatus {
                showLoginPage = true
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showLoginPage: .constant(true))
    }
}

import SwiftUI
import CryptoKit
import AuthenticationServices
import Firebase

class LoginViewModel: ObservableObject {
    
    @Published var nonce = ""
    @AppStorage("loginStatus") var loginStatus = false
    
    func authenticate(credential: ASAuthorizationAppleIDCredential) {
        
        guard let token = credential.identityToken else {
            print("error with firebase")
            return
        }
        
        guard let tokenString = String(data: token, encoding: .utf8) else {
            print("error with Token")
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: tokenString,rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { (result, err) in
            
            if let error = err{
                print(error.localizedDescription)
                return
            }
            
            // User Successfully Logged Into Firebase...
            print("Logged In Success")
            self.loginStatus = true
            withAnimation(.easeInOut) {
                UserDefaults.standard.set(self.loginStatus,
                                          forKey: "loginStatus")
            }
        }
    }
}


extension String {
    func sha256() -> String {
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
