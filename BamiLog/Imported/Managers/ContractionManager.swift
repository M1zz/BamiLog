//
//  ContractionManager.swift
//  laborBreath
//
//  Created by Claude on 11/14/24.
//

import SwiftUI

struct Contraction: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    var duration: TimeInterval? // 수축 지속 시간 (초)
    var painLevel: Int? // 아파요 버튼 누른 횟수

    init(id: UUID = UUID(), timestamp: Date, duration: TimeInterval? = nil, painLevel: Int? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.duration = duration
        self.painLevel = painLevel
    }
}

enum LaborStage {
    case none
    case early // 초기 진통기: 5-30분 간격
    case active // 활발한 진통기: 3-5분 간격
    case transition // 이행기: 1-2분 간격

    var title: String {
        switch self {
        case .none: return "진통 대기 중"
        case .early: return "초기 진통기"
        case .active: return "활발한 진통기"
        case .transition: return "이행기"
        }
    }

    var description: String {
        switch self {
        case .none: return "진통이 시작되면 기록해주세요"
        case .early: return "긴장을 풀고 편안하게 호흡하세요"
        case .active: return "병원 출발 준비를 시작하세요"
        case .transition: return "곧 아기를 만날 수 있어요!"
        }
    }

    var color: Color {
        switch self {
        case .none: return .gray
        case .early: return .green
        case .active: return .orange
        case .transition: return .red
        }
    }
}

class ContractionManager: ObservableObject {
    @Published var contractions: [Contraction] = []

    private let contractionsFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("contractions.json")

    init() {
        loadContractions()
    }

    func recordContraction(duration: TimeInterval? = nil, painLevel: Int? = nil) {
        let newContraction = Contraction(timestamp: Date(), duration: duration, painLevel: painLevel)
        contractions.insert(newContraction, at: 0)
        saveContractions()
    }

    func deleteAllContractions() {
        contractions.removeAll()
        do {
            try FileManager.default.removeItem(at: contractionsFileURL)
        } catch {
            print("Failed to delete contractions file: \(error)")
        }
    }

    func deleteContraction(at offsets: IndexSet) {
        contractions.remove(atOffsets: offsets)
        saveContractions()
    }

    // 평균 진통 간격 계산 (분)
    var averageInterval: Double? {
        guard contractions.count >= 2 else { return nil }

        let recentContractions = Array(contractions.prefix(5)) // 최근 5개
        var intervals: [TimeInterval] = []

        for i in 0..<(recentContractions.count - 1) {
            let interval = recentContractions[i].timestamp.timeIntervalSince(recentContractions[i + 1].timestamp)
            intervals.append(interval)
        }

        let average = intervals.reduce(0, +) / Double(intervals.count)
        return average / 60 // 초를 분으로 변환
    }

    // 현재 진통 단계 판단
    var currentStage: LaborStage {
        guard let avgInterval = averageInterval else { return .none }

        if avgInterval >= 5 && avgInterval <= 30 {
            return .early
        } else if avgInterval >= 3 && avgInterval < 5 {
            return .active
        } else if avgInterval >= 1 && avgInterval < 3 {
            return .transition
        }

        return .none
    }

    // 가장 최근 진통 간격
    var lastInterval: TimeInterval? {
        guard contractions.count >= 2 else { return nil }
        return contractions[0].timestamp.timeIntervalSince(contractions[1].timestamp)
    }

    private func saveContractions() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(contractions)
            try data.write(to: contractionsFileURL)
        } catch {
            print("Failed to save contractions: \(error)")
        }
    }

    private func loadContractions() {
        do {
            let data = try Data(contentsOf: contractionsFileURL)
            let decoder = JSONDecoder()
            let loadedContractions = try decoder.decode([Contraction].self, from: data)
            contractions = loadedContractions.sorted { $0.timestamp > $1.timestamp }
        } catch {
            print("No contractions found or failed to load contractions: \(error)")
        }
    }
}
