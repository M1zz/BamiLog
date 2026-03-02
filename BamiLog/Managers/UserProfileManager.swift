//
//  UserProfileManager.swift
//  BamiLog
//
//  Created by Leeo on 11/16/25.
//

import Foundation
import Combine

class UserProfileManager: ObservableObject {
    @Published var profile: UserProfile?
    @Published var hasCompletedOnboarding: Bool = false

    private let profileFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("userProfile.json")

    init() {
        loadProfile()
    }

    // 프로필 저장
    func saveProfile(_ profile: UserProfile) {
        self.profile = profile
        self.hasCompletedOnboarding = true

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(profile)
            try data.write(to: profileFileURL)
        } catch {
            print("Failed to save profile: \(error)")
        }
    }

    // 프로필 업데이트
    func updateProfile(_ profile: UserProfile) {
        saveProfile(profile)
    }

    // 프로필 로드
    private func loadProfile() {
        do {
            let data = try Data(contentsOf: profileFileURL)
            let decoder = JSONDecoder()
            let loadedProfile = try decoder.decode(UserProfile.self, from: data)
            self.profile = loadedProfile
            self.hasCompletedOnboarding = true
        } catch {
            print("No profile found or failed to load profile: \(error)")
            self.hasCompletedOnboarding = false
        }
    }

    // 온보딩 완료 여부 확인
    func checkOnboardingStatus() -> Bool {
        return hasCompletedOnboarding && profile != nil
    }
}
