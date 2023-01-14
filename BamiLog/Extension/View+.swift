//
//  View+.swift
//  MyBullet
//
//  Created by Roen White on 2023/01/10.
//

import SwiftUI

// MARK: View Extentsions For UI Building
extension View {
    func setHorizontalAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func setVerticalAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
}
