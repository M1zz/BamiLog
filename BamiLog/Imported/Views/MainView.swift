//
//  MainView.swift
//  laborBreath
//
//  Created by Claude on 11/14/24.
//

import SwiftUI

struct MainView: View {
    @StateObject private var appState = AppState()
    @StateObject private var contractionManager = ContractionManager()

    var body: some View {
        Group {
            // 현재 페이즈에 따른 화면 표시
            switch appState.currentPhase {
            case .contractionTracking, .breathingGuide:
                // 페이즈 1, 2: 진통 추적 및 호흡 가이드
                NavigationView {
                    ZStack {
                        switch appState.currentPhase {
                        case .contractionTracking:
                            ContractionTrackingPhaseView()
                                .environmentObject(contractionManager)
                                .environmentObject(appState)
                        case .breathingGuide:
                            BreathingGuidePhaseView()
                                .environmentObject(appState)
                                .overlay(alignment: .topTrailing) {
                                    // 설정 버튼을 오버레이로 표시 (호흡 가이드에만)
                                    Button(action: {
                                        appState.showSettings = true
                                    }) {
                                        Image(systemName: "gear")
                                            .font(.system(size: 20))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .padding(.top, 16)
                                    .padding(.trailing, 16)
                                }
                        case .babyCare:
                            EmptyView()
                        }
                    }
                    .navigationBarHidden(true)
                    .sheet(isPresented: $appState.showSettings) {
                        SettingsView()
                            .environmentObject(appState)
                            .environmentObject(contractionManager)
                    }
                }

            case .babyCare:
                // 페이즈 3: 아기 돌봄 (MenuView는 자체 NavigationStack 포함)
                MenuView()
                    .environmentObject(appState)
                    .overlay(alignment: .topTrailing) {
                        Button(action: {
                            appState.showSettings = true
                        }) {
                            Image(systemName: "gear")
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                                .padding()
                        }
                    }
                    .sheet(isPresented: $appState.showSettings) {
                        SettingsView()
                            .environmentObject(appState)
                            .environmentObject(contractionManager)
                    }
            }
        }
    }
}

#Preview {
    MainView()
}
