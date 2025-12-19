//
//  UserProfile.swift
//  BamiLog
//
//  Created by Leeo on 11/16/25.
//

import Foundation

// 사용자 역할
enum UserRole: String, Codable, CaseIterable {
    case firstTimeMother = "초산모"
    case experiencedMother = "경산모"
    case father = "아빠"

    var isMotherRole: Bool {
        return self == .firstTimeMother || self == .experiencedMother
    }

    var icon: String {
        switch self {
        case .firstTimeMother: return "figure.stand"
        case .experiencedMother: return "figure.and.child.holdinghands"
        case .father: return "figure.walk"
        }
    }

    var description: String {
        switch self {
        case .firstTimeMother: return "첫 출산을 준비하는 산모"
        case .experiencedMother: return "둘째 이상 출산 경험이 있는 산모"
        case .father: return "출산을 함께 하는 아빠"
        }
    }
}

// 엄마 상태
enum MotherStatus: String, Codable, CaseIterable {
    case pregnant = "임신 중"
    case postpartum = "출산 완료"
}

// 아기 성별
enum BabyGender: String, Codable, CaseIterable {
    case male = "남자"
    case female = "여자"
    case unknown = "아직 모름"
}

// 성장 단계
enum GrowthStage: Codable {
    case pregnant(weeks: Int) // 임신 주차
    case postpartum(months: Int) // 출산 후 개월 수

    var description: String {
        switch self {
        case .pregnant(let weeks):
            return "\(weeks)주차"
        case .postpartum(let months):
            return "생후 \(months)개월"
        }
    }
}

// 사용자 프로필
struct UserProfile: Codable {
    var userRole: UserRole
    var motherStatus: MotherStatus
    var babyName: String?
    var babyGender: BabyGender
    var growthStage: GrowthStage?

    // 생리 주기 관련
    var averageCycleLength: Int? // 평균 주기 (일)
    var lastPeriodDate: Date? // 마지막 생리 시작일

    // 임신 정보 관련
    var pregnancyStartDate: Date? // 임신 시작일 (LMP)

    init(
        userRole: UserRole = .firstTimeMother,
        motherStatus: MotherStatus = .pregnant,
        babyName: String? = nil,
        babyGender: BabyGender = .unknown,
        growthStage: GrowthStage? = nil,
        averageCycleLength: Int? = nil,
        lastPeriodDate: Date? = nil,
        pregnancyStartDate: Date? = nil
    ) {
        self.userRole = userRole
        self.motherStatus = motherStatus
        self.babyName = babyName
        self.babyGender = babyGender
        self.growthStage = growthStage
        self.averageCycleLength = averageCycleLength
        self.lastPeriodDate = lastPeriodDate
        self.pregnancyStartDate = pregnancyStartDate
    }
}
