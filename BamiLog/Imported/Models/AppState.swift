//
//  AppState.swift
//  laborBreath
//
//  Created by Claude on 11/14/24.
//

import SwiftUI

enum AppPhase: Int, CaseIterable, Identifiable {
    case contractionTracking = 1 // 페이즈 1: 진통 기록
    case breathingGuide = 2      // 페이즈 2: 호흡 가이드
    case babyCare = 3            // 페이즈 3: 아기 돌봄

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .contractionTracking:
            return "진통 기록"
        case .breathingGuide:
            return "호흡 가이드"
        case .babyCare:
            return "아기 돌봄"
        }
    }

    var description: String {
        switch self {
        case .contractionTracking:
            return "진통 간격을 기록하고 출산 시기를 파악합니다"
        case .breathingGuide:
            return "호흡법을 통해 진통을 관리합니다"
        case .babyCare:
            return "아기의 수유, 수면, 기저귀 등을 기록합니다"
        }
    }

    var icon: String {
        switch self {
        case .contractionTracking:
            return "heart.text.square"
        case .breathingGuide:
            return "wind"
        case .babyCare:
            return "figure.and.child.holdinghands"
        }
    }
}

class AppState: ObservableObject {
    @Published var currentPhase: AppPhase = .contractionTracking {
        didSet {
            // 페이즈가 변경되면 앱 아이콘도 변경
            AppIconManager.shared.setIconForPhase(currentPhase)
        }
    }
    @Published var showSettings: Bool = false
    @Published var isContracting: Bool = false // 진통 중 상태

    init() {
        // 초기화 시 현재 페이즈에 맞는 아이콘 설정
        AppIconManager.shared.setIconForPhase(currentPhase)
    }

    func moveToNextPhase() {
        switch currentPhase {
        case .contractionTracking:
            currentPhase = .breathingGuide
        case .breathingGuide:
            currentPhase = .babyCare
        case .babyCare:
            // 마지막 페이즈이므로 아무것도 하지 않음
            break
        }
    }

    func moveToPreviousPhase() {
        switch currentPhase {
        case .contractionTracking:
            // 첫 번째 페이즈이므로 아무것도 하지 않음
            break
        case .breathingGuide:
            currentPhase = .contractionTracking
        case .babyCare:
            currentPhase = .breathingGuide
        }
    }
}
