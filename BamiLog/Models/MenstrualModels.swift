//
//  MenstrualModels.swift
//  BamiLog
//
//  Created by Claude on 12/16/25.
//

import Foundation

// MARK: - 일별 기록

struct DailyLog: Identifiable, Codable {
    let id: UUID
    var date: Date
    var flowLevel: FlowLevel?
    var symptoms: [Symptom]
    var notes: String?

    init(
        id: UUID = UUID(),
        date: Date,
        flowLevel: FlowLevel? = nil,
        symptoms: [Symptom] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.flowLevel = flowLevel
        self.symptoms = symptoms
        self.notes = notes
    }
}

// MARK: - 생리 주기 모델

struct MenstrualCycle: Identifiable, Codable {
    let id: UUID
    var startDate: Date
    var endDate: Date?
    var cycleLength: Int? // 이번 주기 길이 (일)
    var periodLength: Int? // 생리 지속 기간 (일)
    var dailyLogs: [DailyLog] // 일별 기록
    var notes: String?

    // 계산 속성
    var isOngoing: Bool {
        return endDate == nil
    }

    // 모든 증상 수집
    var allSymptoms: [Symptom] {
        return dailyLogs.flatMap { $0.symptoms }
    }

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date? = nil,
        cycleLength: Int? = nil,
        periodLength: Int? = nil,
        dailyLogs: [DailyLog] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.cycleLength = cycleLength
        self.periodLength = periodLength
        self.dailyLogs = dailyLogs
        self.notes = notes
    }
}

// MARK: - 출혈량 타입

enum FlowLevel: String, Codable, CaseIterable {
    case spotting = "소량"
    case light = "적음"
    case medium = "보통"
    case heavy = "많음"
    case veryHeavy = "매우 많음"

    var icon: String {
        switch self {
        case .spotting:
            return "drop"
        case .light:
            return "drop.fill"
        case .medium:
            return "drop.triangle"
        case .heavy:
            return "drop.triangle.fill"
        case .veryHeavy:
            return "drop.halffull"
        }
    }

    var color: String {
        switch self {
        case .spotting:
            return "pink"
        case .light:
            return "pink"
        case .medium:
            return "red"
        case .heavy:
            return "red"
        case .veryHeavy:
            return "darkRed"
        }
    }
}

// MARK: - 증상 타입

enum SymptomType: String, Codable, CaseIterable {
    case cramps = "생리통"
    case headache = "두통"
    case bloating = "복부팽만"
    case moodSwings = "기분변화"
    case fatigue = "피로"
    case backPain = "요통"
    case acne = "여드름"
    case breastTenderness = "유방통증"

    var icon: String {
        switch self {
        case .cramps:
            return "bolt.fill"
        case .headache:
            return "brain.head.profile"
        case .bloating:
            return "cylinder.fill"
        case .moodSwings:
            return "face.dashed"
        case .fatigue:
            return "bed.double.fill"
        case .backPain:
            return "figure.walk"
        case .acne:
            return "circle.hexagongrid.fill"
        case .breastTenderness:
            return "heart.circle.fill"
        }
    }
}

// MARK: - 증상 기록

struct Symptom: Identifiable, Codable {
    let id: UUID
    var type: SymptomType
    var severity: Int // 1-5
    var date: Date

    init(
        id: UUID = UUID(),
        type: SymptomType,
        severity: Int,
        date: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.severity = severity
        self.date = date
    }
}

// MARK: - 배란 예측 정보

struct OvulationPrediction {
    var predictedOvulationDate: Date
    var fertileWindowStart: Date
    var fertileWindowEnd: Date
    var confidence: Double // 0.0 - 1.0
}
