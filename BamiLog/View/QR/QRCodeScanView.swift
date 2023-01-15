//
//  QRCodeScanView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/15.
//

import SwiftUI

struct QRCodeScanView: View {
    
    @StateObject var viewModel = QRCodeScanViewModel()
    @Binding var needPresentGroupCode: Bool
    @State var userGroupCode: String
    
    private let imageLength: CGFloat? = 275
    
    
    var body: some View {
        let dashedRectangle = Rectangle().stroke(Color.yellow,
                                                 style: StrokeStyle(lineWidth: 5.0,
                                                                    lineCap: .round,
                                                                    lineJoin: .bevel,
                                                                    dash: [60, 215],
                                                                    dashPhase: 29))
        
        VStack {
            if !needPresentGroupCode {
                Text("참여한 그룹코드 : \(userGroupCode)")
            }
            
            ScannerView(scannedCode: $viewModel.scannedCode,
                        alertItem: $viewModel.alertItem)
                .frame(maxWidth: imageLength,
                       maxHeight: imageLength)
                .overlay(dashedRectangle)
            
            Spacer().frame(height: 60)
            
            
            
            Label("QR을 스캔해주세요:",
                  systemImage: "qrcode.viewfinder")
                .font(.title)
            
            Text(viewModel.statusText)
                .bold()
                .font(.largeTitle)
                .foregroundColor(viewModel.statusTextColor)
                .padding()
        }
        .onAppear(perform: {
            if let groupCode = UserDefaults.standard.string(forKey: "groupCode") {
                needPresentGroupCode = false
                userGroupCode = groupCode
            } else {
                needPresentGroupCode = true
            }
        })
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: Text(alertItem.title),
                  message: Text(alertItem.message),
                  dismissButton: alertItem.dismissButton)
        }
    }
}

struct QRCodeScanView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScanView(needPresentGroupCode: .constant(false),
                       userGroupCode: "리25")
    }
}

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

final class QRCodeScanViewModel: ObservableObject {
    
    @Published var scannedCode = ""
    @Published var alertItem: AlertItem?
    //private let ref = Database.database().reference(withPath: "attend-history")
    
    var statusText: String {
        if scannedCode.isEmpty {
            return ScanMessage.needInput
        } else {
            UserDefaults.standard.set(scannedCode,
                                      forKey: "groupCode")
            return ScanMessage.approved
        }
    }
    
    var statusTextColor: Color {
        if scannedCode.isEmpty {
            return .red
        } else {
            return .green
        }
    }
    
    
}

enum ScanMessage {
    static let needInput = "입력이 필요합니다."
    static let approved = "성공 했습니다."
    static let invalidCode = "유효하지 않은 코드입니다."
}
