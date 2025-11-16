//
//  MainTabView.swift
//  laborBreath
//
//  Created by Claude on 11/14/24.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var contractionManager = ContractionManager()

    var body: some View {
        TabView {
            BreathGuideView()
                .tabItem {
                    Label("호흡 가이드", systemImage: "wind")
                }

            ContractionTrackerView()
                .environmentObject(contractionManager)
                .tabItem {
                    Label("진통 기록", systemImage: "heart.text.square")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}
