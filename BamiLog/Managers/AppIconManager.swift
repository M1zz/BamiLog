//
//  AppIconManager.swift
//  BamiLog
//
//  Created by hyunho lee on 11/16/25.
//

import UIKit

class AppIconManager {
    static let shared = AppIconManager()

    private init() {}

    enum AppIcon: String, CaseIterable {
        // 페이즈별 아이콘
        case phase1 = "AppIcon-Phase1"
        case phase2 = "AppIcon-Phase2"
        case phase3 = "AppIcon-Phase3"
        case phase4 = "AppIcon-Phase4"

        // 역할별 아이콘
        case firstTimeMother = "AppIcon-FirstTimeMother"
        case experiencedMother = "AppIcon-ExperiencedMother"
        case father = "AppIcon-Father"

        var displayName: String {
            switch self {
            case .phase1:
                return "진통 추적"
            case .phase2:
                return "호흡 가이드"
            case .phase3:
                return "아기 돌봄"
            case .phase4:
                return "성장 기록"
            case .firstTimeMother:
                return "초산모"
            case .experiencedMother:
                return "경산모"
            case .father:
                return "아빠"
            }
        }

        var iconName: String? {
            switch self {
            case .phase1:
                return "AppIcon-Phase1"
            case .phase2:
                return "AppIcon-Phase2"
            case .phase3:
                return "AppIcon-Phase3"
            case .phase4:
                return "AppIcon-Phase4"
            case .firstTimeMother:
                return "AppIcon-FirstTimeMother"
            case .experiencedMother:
                return "AppIcon-ExperiencedMother"
            case .father:
                return "AppIcon-Father"
            }
        }
    }

    var currentIcon: AppIcon {
        guard let iconName = UIApplication.shared.alternateIconName else {
            return .phase1 // 기본 아이콘
        }
        return AppIcon(rawValue: iconName) ?? .phase1
    }

    func setIcon(_ icon: AppIcon, completion: ((Bool) -> Void)? = nil) {
        guard UIApplication.shared.supportsAlternateIcons else {
            completion?(false)
            return
        }

        // 현재 아이콘과 같으면 변경하지 않음
        if currentIcon == icon {
            completion?(true)
            return
        }

        UIApplication.shared.setAlternateIconName(icon.iconName) { error in
            if let error = error {
                print("앱 아이콘 변경 실패: \(error.localizedDescription)")
                completion?(false)
            } else {
                print("앱 아이콘 변경 성공: \(icon.displayName)")
                completion?(true)
            }
        }
    }

    func setIconForPhase(_ phase: AppPhase) {
        let icon: AppIcon
        switch phase {
        case .menstrualTracking:
            icon = .phase1
        case .pregnancy:
            icon = .phase2
        case .laborAndBirth:
            icon = .phase3
        case .babyCare:
            icon = .phase3
        case .growthDiary:
            icon = .phase4
        }

        setIcon(icon)
    }

    // 사용자 역할에 따라 아이콘 변경
    func setIconForUserRole(_ role: UserRole) {
        let icon: AppIcon
        switch role {
        case .firstTimeMother:
            icon = .firstTimeMother
        case .experiencedMother:
            icon = .experiencedMother
        case .father:
            icon = .father
        }

        setIcon(icon)
    }
}
