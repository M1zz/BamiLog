//
//  AppIconManager.swift
//  BamiLog
//
//  Created by Claude on 11/15/24.
//

import UIKit

class AppIconManager {
    static let shared = AppIconManager()

    private init() {}

    enum AppIcon: String, CaseIterable {
        case phase1 = "AppIcon-Phase1"
        case phase2 = "AppIcon-Phase2"
        case phase3 = "AppIcon-Phase3"

        var displayName: String {
            switch self {
            case .phase1:
                return "진통 추적"
            case .phase2:
                return "호흡 가이드"
            case .phase3:
                return "아기 돌봄"
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
        case .contractionTracking:
            icon = .phase1
        case .breathingGuide:
            icon = .phase2
        case .babyCare:
            icon = .phase3
        }

        setIcon(icon)
    }
}
