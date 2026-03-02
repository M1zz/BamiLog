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
        case defaultIcon = "AppIcon"
        case phase2 = "AppIcon-Phase2"

        var displayName: String {
            switch self {
            case .defaultIcon:
                return "기본"
            case .phase2:
                return "호흡 가이드"
            }
        }

        /// nil이면 기본 아이콘으로 복원
        var iconName: String? {
            switch self {
            case .defaultIcon:
                return nil
            case .phase2:
                return "AppIcon-Phase2"
            }
        }
    }

    var currentIcon: AppIcon {
        guard let iconName = UIApplication.shared.alternateIconName else {
            return .defaultIcon
        }
        return AppIcon(rawValue: iconName) ?? .defaultIcon
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
        case .pregnancy:
            icon = .phase2
        default:
            icon = .defaultIcon
        }

        setIcon(icon)
    }

    func setIconForUserRole(_ role: UserRole) {
        // 역할별 아이콘 에셋이 아직 없으므로 기본 아이콘 유지
        setIcon(.defaultIcon)
    }
}
