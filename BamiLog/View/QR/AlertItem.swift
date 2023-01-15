//
//  AlertItem.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/15.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let dismissButton: Alert.Button
}


struct AlertContext {
    static let invalidDeviceInput = AlertItem(title: "유효하지 않은 입력",
                                              message: "카메라에 문제가 발생했습니다. 입력값을 인식하지 못 합니다.",
                                              dismissButton: .default(Text("OK")))
    
    static let invalidScannedType = AlertItem(title: "유효하지 않은 스캔타입",
                                              message: "스캔타입이 유효하지 않습니다. 이 앱은 QR코드만 인식합니다.",
                                              dismissButton: .default(Text("OK")))
}
