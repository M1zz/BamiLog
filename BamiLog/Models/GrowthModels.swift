//
//  GrowthModels.swift
//  BamiLog
//
//  Created by Claude on 11/17/24.
//

import Foundation
import SwiftUI

// MARK: - Growth Record (키, 몸무게 기록)
struct GrowthRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var heightCm: Double?      // 키 (cm)
    var weightKg: Double?      // 몸무게 (kg)
    var headCircumferenceCm: Double? // 머리 둘레 (cm) - 선택사항
    var note: String?          // 메모

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        heightCm: Double? = nil,
        weightKg: Double? = nil,
        headCircumferenceCm: Double? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.date = date
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.headCircumferenceCm = headCircumferenceCm
        self.note = note
    }
}

// MARK: - Diary Entry (일기)
struct DiaryEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var title: String
    var content: String
    var type: DiaryType
    var photos: [String]       // 사진 파일명들
    var mood: Mood?            // 아이의 기분

    // 템플릿 전용 필드
    var mealInfo: MealInfo?
    var sleepInfo: SleepInfo?
    var activityInfo: ActivityInfo?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        title: String = "",
        content: String = "",
        type: DiaryType = .free,
        photos: [String] = [],
        mood: Mood? = nil,
        mealInfo: MealInfo? = nil,
        sleepInfo: SleepInfo? = nil,
        activityInfo: ActivityInfo? = nil
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.content = content
        self.type = type
        self.photos = photos
        self.mood = mood
        self.mealInfo = mealInfo
        self.sleepInfo = sleepInfo
        self.activityInfo = activityInfo
    }
}

enum DiaryType: String, Codable {
    case free = "자유 일기"
    case meal = "식사 기록"
    case sleep = "수면 기록"
    case activity = "활동 기록"
}

enum Mood: String, Codable, CaseIterable {
    case veryHappy = "😄"
    case happy = "😊"
    case neutral = "😐"
    case sad = "😢"
    case angry = "😠"

    var description: String {
        switch self {
        case .veryHappy: return "매우 기뻐요"
        case .happy: return "기뻐요"
        case .neutral: return "보통이에요"
        case .sad: return "슬퍼요"
        case .angry: return "화나요"
        }
    }
}

// 템플릿 전용 구조체들
struct MealInfo: Codable, Hashable {
    var mealType: String      // 아침, 점심, 저녁, 간식
    var foods: [String]       // 먹은 음식들
    var amount: String        // 양 (많이, 보통, 조금)
}

struct SleepInfo: Codable, Hashable {
    var startTime: Date
    var endTime: Date
    var quality: String       // 좋음, 보통, 나쁨
}

struct ActivityInfo: Codable, Hashable {
    var activityType: String  // 놀이, 산책, 학습 등
    var duration: Int         // 분 단위
    var location: String?     // 장소
}

// MARK: - Milestone (발달 이정표)
struct Milestone: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var category: MilestoneCategory
    var title: String
    var description: String
    var photos: [String]
    var isAchieved: Bool

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        category: MilestoneCategory,
        title: String,
        description: String = "",
        photos: [String] = [],
        isAchieved: Bool = false
    ) {
        self.id = id
        self.date = date
        self.category = category
        self.title = title
        self.description = description
        self.photos = photos
        self.isAchieved = isAchieved
    }
}

enum MilestoneCategory: String, Codable, CaseIterable {
    case physical = "신체 발달"
    case cognitive = "인지 발달"
    case social = "사회성 발달"
    case language = "언어 발달"
    case special = "특별한 순간"

    var icon: String {
        switch self {
        case .physical: return "figure.walk"
        case .cognitive: return "brain.head.profile"
        case .social: return "person.2.fill"
        case .language: return "text.bubble.fill"
        case .special: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .physical: return AppColors.phase1
        case .cognitive: return AppColors.phase2
        case .social: return AppColors.phase3
        case .language: return AppColors.info
        case .special: return AppColors.warning
        }
    }

    // 기본 이정표들
    static var defaultMilestones: [Milestone] {
        [
            Milestone(category: .physical, title: "첫 미소", description: "아기가 처음으로 미소를 지었어요"),
            Milestone(category: .physical, title: "목 가누기", description: "스스로 목을 가눌 수 있어요"),
            Milestone(category: .physical, title: "뒤집기", description: "배에서 등으로 뒤집었어요"),
            Milestone(category: .physical, title: "기어다니기", description: "혼자서 기어다녀요"),
            Milestone(category: .physical, title: "첫 걸음", description: "첫 걸음을 떼었어요"),
            Milestone(category: .language, title: "옹알이", description: "옹알이를 시작했어요"),
            Milestone(category: .language, title: "첫 단어", description: "의미있는 첫 단어를 말했어요"),
            Milestone(category: .social, title: "눈맞춤", description: "엄마/아빠와 눈을 맞춰요"),
            Milestone(category: .special, title: "첫 이빨", description: "첫 이빨이 났어요"),
            Milestone(category: .special, title: "첫 생일", description: "첫 번째 생일이에요")
        ]
    }
}

// MARK: - Tooth Record (이빨 성장 기록)
struct ToothRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var toothPosition: ToothPosition
    var dateErupted: Date?     // 이빨이 난 날짜
    var dateLost: Date?        // 이빨이 빠진 날짜 (유치용)
    var note: String?

    init(
        id: UUID = UUID(),
        toothPosition: ToothPosition,
        dateErupted: Date? = nil,
        dateLost: Date? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.toothPosition = toothPosition
        self.dateErupted = dateErupted
        self.dateLost = dateLost
        self.note = note
    }
}

enum ToothPosition: String, Codable, CaseIterable {
    // 윗니 (상악)
    case upperCentralIncisor1 = "상악 중절치 1"
    case upperCentralIncisor2 = "상악 중절치 2"
    case upperLateralIncisor1 = "상악 측절치 1"
    case upperLateralIncisor2 = "상악 측절치 2"
    case upperCanine1 = "상악 송곳니 1"
    case upperCanine2 = "상악 송곳니 2"
    case upperFirstMolar1 = "상악 제1 대구치 1"
    case upperFirstMolar2 = "상악 제1 대구치 2"
    case upperSecondMolar1 = "상악 제2 대구치 1"
    case upperSecondMolar2 = "상악 제2 대구치 2"

    // 아랫니 (하악)
    case lowerCentralIncisor1 = "하악 중절치 1"
    case lowerCentralIncisor2 = "하악 중절치 2"
    case lowerLateralIncisor1 = "하악 측절치 1"
    case lowerLateralIncisor2 = "하악 측절치 2"
    case lowerCanine1 = "하악 송곳니 1"
    case lowerCanine2 = "하악 송곳니 2"
    case lowerFirstMolar1 = "하악 제1 대구치 1"
    case lowerFirstMolar2 = "하악 제1 대구치 2"
    case lowerSecondMolar1 = "하악 제2 대구치 1"
    case lowerSecondMolar2 = "하악 제2 대구치 2"

    var simpleName: String {
        switch self {
        case .upperCentralIncisor1, .upperCentralIncisor2: return "윗니 앞니"
        case .upperLateralIncisor1, .upperLateralIncisor2: return "윗니 옆니"
        case .upperCanine1, .upperCanine2: return "윗니 송곳니"
        case .upperFirstMolar1, .upperFirstMolar2: return "윗니 어금니1"
        case .upperSecondMolar1, .upperSecondMolar2: return "윗니 어금니2"
        case .lowerCentralIncisor1, .lowerCentralIncisor2: return "아랫니 앞니"
        case .lowerLateralIncisor1, .lowerLateralIncisor2: return "아랫니 옆니"
        case .lowerCanine1, .lowerCanine2: return "아랫니 송곳니"
        case .lowerFirstMolar1, .lowerFirstMolar2: return "아랫니 어금니1"
        case .lowerSecondMolar1, .lowerSecondMolar2: return "아랫니 어금니2"
        }
    }

    var isUpper: Bool {
        rawValue.hasPrefix("상악")
    }
}
