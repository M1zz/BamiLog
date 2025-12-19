//
//  PregnancyModels.swift
//  BamiLog
//
//  Created by Claude on 12/16/25.
//

import Foundation

// MARK: - 임신 정보

struct PregnancyInfo: Codable {
    var babyName: String? // 태명
    var lastPeriodDate: Date // 마지막 생리 시작일 (LMP)
    var expectedDueDate: Date // 예상 출산일
    var currentWeek: Int // 현재 임신 주차
    var currentDay: Int // 현재 임신 일차

    // 계산 속성
    var isLaborReady: Bool {
        return currentWeek >= 36
    }

    // 임신 분기
    var trimester: Int {
        if currentWeek <= 13 {
            return 1
        } else if currentWeek <= 27 {
            return 2
        } else {
            return 3
        }
    }

    // D-Day 계산
    var daysUntilDueDate: Int {
        return Calendar.current.dateComponents([.day], from: Date(), to: expectedDueDate).day ?? 0
    }

    init(
        babyName: String? = nil,
        lastPeriodDate: Date,
        expectedDueDate: Date,
        currentWeek: Int,
        currentDay: Int
    ) {
        self.babyName = babyName
        self.lastPeriodDate = lastPeriodDate
        self.expectedDueDate = expectedDueDate
        self.currentWeek = currentWeek
        self.currentDay = currentDay
    }
}

// MARK: - 주차별 태아 발달 정보

struct WeeklyFetalDevelopment {
    let week: Int
    let title: String
    let description: String
    let fetalSize: String // 예: "사과만한 크기"
    let fetalWeight: String // 예: "약 100g"
    let keyMilestones: [String] // 주요 발달 이정표
    let icon: String
}

// MARK: - 주차별 산모 건강 가이드

struct WeeklyMotherGuide {
    let week: Int
    let title: String
    let tips: [String]
    let warnings: [String]
    let commonSymptoms: [String]
}

// MARK: - 주차별 아빠 가이드

struct WeeklyFatherGuide {
    let week: Int
    let title: String
    let whatToDo: [String] // 아빠가 해야 할 일
    let emotionalSupport: [String] // 정서적 지원
    let practicalHelp: [String] // 실질적 도움
}

// MARK: - 검진 일정

struct CheckupSchedule: Identifiable, Codable {
    let id: UUID
    var title: String
    var scheduledDate: Date
    var isCompleted: Bool
    var notes: String?
    var checkupType: CheckupType

    init(
        id: UUID = UUID(),
        title: String,
        scheduledDate: Date,
        isCompleted: Bool = false,
        notes: String? = nil,
        checkupType: CheckupType = .regular
    ) {
        self.id = id
        self.title = title
        self.scheduledDate = scheduledDate
        self.isCompleted = isCompleted
        self.notes = notes
        self.checkupType = checkupType
    }
}

// MARK: - 검진 타입

enum CheckupType: String, Codable, CaseIterable {
    case regular = "정기 검진"
    case ultrasound = "초음파 검사"
    case bloodTest = "혈액 검사"
    case glucose = "당뇨 검사"
    case special = "특수 검사"

    var icon: String {
        switch self {
        case .regular:
            return "stethoscope"
        case .ultrasound:
            return "waveform.path.ecg"
        case .bloodTest:
            return "drop.fill"
        case .glucose:
            return "cross.vial.fill"
        case .special:
            return "heart.text.square.fill"
        }
    }
}
