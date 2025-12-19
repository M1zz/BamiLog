//
//  LaborAndBreathingPhaseView.swift
//  BamiLog
//
//  Created by Claude on 12/16/25.
//

import SwiftUI

struct LaborAndBreathingPhaseView: View {
    @EnvironmentObject var contractionManager: ContractionManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userProfileManager: UserProfileManager

    @State private var selectedTab = 0 // 0: 진통 기록, 1: 호흡 가이드

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 탭 선택기
                Picker("", selection: $selectedTab) {
                    Text("진통 기록").tag(0)
                    Text("호흡 가이드").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // 탭 컨텐츠
                TabView(selection: $selectedTab) {
                    // 진통 기록 탭
                    ContractionTrackingPhaseView()
                        .environmentObject(contractionManager)
                        .environmentObject(appState)
                        .environmentObject(userProfileManager)
                        .tag(0)

                    // 호흡 가이드 탭
                    BreathingGuidePhaseView()
                        .environmentObject(appState)
                        .environmentObject(contractionManager)
                        .environmentObject(userProfileManager)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        appState.showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                // 진통 기록 탭 전용 버튼들
                if selectedTab == 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 12) {
                            if appState.isContracting || (!contractionManager.contractions.isEmpty && appState.contractionElapsedTime > 0) {
                                Button(action: {
                                    NotificationCenter.default.post(name: NSNotification.Name("StopContraction"), object: nil)
                                }) {
                                    Image(systemName: "stop.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.orange)
                                }
                            }

                            if !contractionManager.contractions.isEmpty {
                                Button(action: {
                                    NotificationCenter.default.post(name: NSNotification.Name("ShowDeleteAlert"), object: nil)
                                }) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppColors.error)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: appState.isContracting) { isContracting in
            // 진통 시작 시 자동으로 호흡 가이드 탭으로 전환
            if isContracting {
                withAnimation {
                    selectedTab = 1
                }
            }
        }
    }
}
