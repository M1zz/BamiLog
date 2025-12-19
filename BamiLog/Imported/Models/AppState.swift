//
//  AppState.swift
//  laborBreath
//
//  Created by Claude on 11/14/24.
//

import SwiftUI

enum AppPhase: Int, CaseIterable, Identifiable {
    case menstrualTracking = 1  // 페이즈 1: 생리 주기 추적
    case pregnancy = 2          // 페이즈 2: 임신 정보
    case laborAndBirth = 3      // 페이즈 3: 진통 & 호흡
    case babyCare = 4           // 페이즈 4: 아기 돌봄
    case growthDiary = 5        // 페이즈 5: 성장 기록

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .menstrualTracking:
            return "생리 주기"
        case .pregnancy:
            return "임신 정보"
        case .laborAndBirth:
            return "진통 & 출산"
        case .babyCare:
            return "아기 돌봄"
        case .growthDiary:
            return "성장 기록"
        }
    }

    var description: String {
        switch self {
        case .menstrualTracking:
            return "생리 주기를 추적하고 배란일을 예측합니다"
        case .pregnancy:
            return "주차별 임신 정보와 검진 일정을 관리합니다"
        case .laborAndBirth:
            return "진통을 기록하고 호흡법으로 관리합니다"
        case .babyCare:
            return "아기의 수유, 수면, 기저귀 등을 기록합니다"
        case .growthDiary:
            return "아이의 성장 과정과 소중한 순간들을 기록합니다"
        }
    }

    var icon: String {
        switch self {
        case .menstrualTracking:
            return "calendar.circle.fill"
        case .pregnancy:
            return "heart.circle.fill"
        case .laborAndBirth:
            return "waveform.path.ecg"
        case .babyCare:
            return "figure.and.child.holdinghands"
        case .growthDiary:
            return "chart.line.uptrend.xyaxis"
        }
    }
}

class AppState: ObservableObject {
    @AppStorage("currentPhaseKey") private var currentPhaseRawValue: Int = AppPhase.menstrualTracking.rawValue
    @AppStorage("hasCompletedPhaseMigration") private var hasCompletedMigration: Bool = false

    var currentPhase: AppPhase {
        get {
            // 첫 실행 시 마이그레이션
            if !hasCompletedMigration {
                migratePhase()
            }
            return AppPhase(rawValue: currentPhaseRawValue) ?? .menstrualTracking
        }
        set {
            // 페이즈가 변경되면 저장
            currentPhaseRawValue = newValue.rawValue
            objectWillChange.send()
        }
    }

    @Published var showSettings: Bool = false
    @Published var isContracting: Bool = false // 진통 중 상태
    @Published var contractionElapsedTime: TimeInterval = 0 // 진통 경과 시간

    // MARK: - 마이그레이션 로직

    // 기존 Phase 값을 신규 Phase로 마이그레이션
    private func migratePhase() {
        let oldValue = currentPhaseRawValue

        // 기존 값 매핑:
        // 1 (contractionTracking) -> 3 (laborAndBirth)
        // 2 (breathingGuide) -> 3 (laborAndBirth)
        // 3 (babyCare) -> 4 (babyCare)
        // 4 (growthDiary) -> 5 (growthDiary)

        switch oldValue {
        case 1, 2: // 기존 진통/호흡 -> 새 진통
            currentPhaseRawValue = 3
        case 3: // 기존 아기 돌봄 -> 새 아기 돌봄
            currentPhaseRawValue = 4
        case 4: // 기존 성장 기록 -> 새 성장 기록
            currentPhaseRawValue = 5
        default:
            // 알 수 없는 값은 기본값으로
            currentPhaseRawValue = 1
        }

        hasCompletedMigration = true
    }

    // MARK: - Phase 이동

    func moveToNextPhase() {
        let allCases = AppPhase.allCases
        guard let currentIndex = allCases.firstIndex(of: currentPhase) else { return }

        if currentIndex < allCases.count - 1 {
            currentPhase = allCases[currentIndex + 1]
        }
    }

    func moveToPreviousPhase() {
        let allCases = AppPhase.allCases
        guard let currentIndex = allCases.firstIndex(of: currentPhase) else { return }

        if currentIndex > 0 {
            currentPhase = allCases[currentIndex - 1]
        }
    }
}
