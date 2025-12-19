//
//  ContractionManager.swift
//  BamiLog
//
//  Created by hyunho lee on 11/16/25.
//

import SwiftUI

// 호흡 시각화 타입
enum BreathingVisualization: String, Codable, CaseIterable {
    case circle = "circle" // 원형 애니메이션
    case candle = "candle" // 촛불 애니메이션
    case paperBoat = "paperBoat" // 종이배 애니메이션

    var title: String {
        switch self {
        case .circle: return "원형"
        case .candle: return "촛불"
        case .paperBoat: return "종이배"
        }
    }

    var icon: String {
        switch self {
        case .circle: return "circle"
        case .candle: return "flame"
        case .paperBoat: return "paperplane"
        }
    }
}

// 호흡 패턴
enum BreathingPattern: String, Codable, CaseIterable {
    case simple = "simple" // 4-4
    case laborFocused = "laborFocused" // 3-6
    case relaxation = "relaxation" // 4-7-8

    var title: String {
        switch self {
        case .simple: return "간단한 패턴"
        case .laborFocused: return "진통용 패턴"
        case .relaxation: return "4-7-8 호흡법"
        }
    }

    var description: String {
        switch self {
        case .simple: return "4초 들이쉬기 → 4초 내쉬기"
        case .laborFocused: return "3초 들이쉬기 → 6초 내쉬기"
        case .relaxation: return "4초 들이쉬기 → 7초 멈추기 → 8초 내쉬기"
        }
    }

    // 들숨 시간 (초)
    var inhaleTime: Double {
        switch self {
        case .simple: return 4.0
        case .laborFocused: return 3.0
        case .relaxation: return 4.0
        }
    }

    // 숨 멈춤 시간 (초)
    var holdTime: Double {
        switch self {
        case .simple: return 0.0
        case .laborFocused: return 0.0
        case .relaxation: return 7.0
        }
    }

    // 날숨 시간 (초)
    var exhaleTime: Double {
        switch self {
        case .simple: return 4.0
        case .laborFocused: return 6.0
        case .relaxation: return 8.0
        }
    }

    // 전체 사이클 시간 (초)
    var totalCycleTime: Double {
        return inhaleTime + holdTime + exhaleTime
    }
}

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
    @Published var currentContraction: Contraction? // 현재 진행 중인 진통
    @Published var contractionStartTime: Date? // 진통 시작 시간
    @Published var selectedBreathingPattern: BreathingPattern = .laborFocused // 기본값: 진통용 패턴
    @Published var selectedVisualization: BreathingVisualization = .circle // 기본값: 원형

    private let contractionsFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("contractions.json")
    private let breathingPatternKey = "selectedBreathingPattern"
    private let breathingVisualizationKey = "selectedVisualization"

    init() {
        loadContractions()
        loadBreathingPattern()
        loadVisualization()
    }

    // 진통 진행 중인지 확인
    var isContractionInProgress: Bool {
        return currentContraction != nil
    }

    // 진통 시작
    func startContraction() {
        let startTime = Date()
        contractionStartTime = startTime
        currentContraction = Contraction(timestamp: startTime)
    }

    // 진통 종료
    func endContraction(painLevel: Int? = nil) {
        guard let current = currentContraction, let startTime = contractionStartTime else { return }

        let duration = Date().timeIntervalSince(startTime)
        let finishedContraction = Contraction(
            id: current.id,
            timestamp: startTime,
            duration: duration,
            painLevel: painLevel
        )

        contractions.insert(finishedContraction, at: 0)
        saveContractions()

        // 상태 초기화
        currentContraction = nil
        contractionStartTime = nil
    }

    // 진통 취소
    func cancelContraction() {
        currentContraction = nil
        contractionStartTime = nil
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

    // 호흡 패턴 저장
    func saveBreathingPattern(_ pattern: BreathingPattern) {
        selectedBreathingPattern = pattern
        UserDefaults.standard.set(pattern.rawValue, forKey: breathingPatternKey)
    }

    // 호흡 패턴 로드
    private func loadBreathingPattern() {
        if let rawValue = UserDefaults.standard.string(forKey: breathingPatternKey),
           let pattern = BreathingPattern(rawValue: rawValue) {
            selectedBreathingPattern = pattern
        }
    }

    // 호흡 시각화 저장
    func saveVisualization(_ visualization: BreathingVisualization) {
        selectedVisualization = visualization
        UserDefaults.standard.set(visualization.rawValue, forKey: breathingVisualizationKey)
    }

    // 호흡 시각화 로드
    private func loadVisualization() {
        if let rawValue = UserDefaults.standard.string(forKey: breathingVisualizationKey),
           let visualization = BreathingVisualization(rawValue: rawValue) {
            selectedVisualization = visualization
        }
    }
}

// MARK: - 진통 행동 가이드

/// 진통 단계별 행동 가이드
enum ContractionPhase {
    case beforeContraction  // 진통 시작 전
    case contractionStart   // 진통 시작 (0-15초)
    case contractionPeak    // 진통 정점 (15초 이후)
    case contractionEnd     // 진통 종료 직전
    case restPeriod         // 휴식기 (진통 사이)
}

/// 진통 중 행동 가이드 메시지
struct ContractionActionGuide {

    /// 역할별, 단계별 행동 가이드 메시지
    static func getActionMessage(for phase: ContractionPhase, userRole: UserRole) -> String? {
        switch userRole {
        case .father:
            return getFatherGuidance(for: phase)
        case .firstTimeMother, .experiencedMother:
            return getMotherGuidance(for: phase)
        }
    }

    /// 아빠를 위한 행동 가이드
    private static func getFatherGuidance(for phase: ContractionPhase) -> String? {
        switch phase {
        case .beforeContraction:
            return nil

        case .contractionStart:
            return [
                "지금은 산모의 손을 잡아주세요",
                "산모 곁에 가까이 있어주세요",
                "함께 호흡할 준비를 해주세요",
                "산모의 눈을 바라봐주세요"
            ].randomElement()

        case .contractionPeak:
            return [
                "허리 아래를 원을 그리며 눌러주세요",
                "지금은 말 걸지 말고 함께 숨만 쉬세요",
                "산모의 손을 계속 잡아주세요",
                "등을 부드럽게 쓸어주세요",
                "천천히 함께 호흡해주세요"
            ].randomElement()

        case .contractionEnd:
            return [
                "잘하고 있어요. 곧 끝나요",
                "조금만 더 힘내세요",
                "거의 다 왔어요"
            ].randomElement()

        case .restPeriod:
            return [
                "수축 사이에 물을 한 모금 주세요",
                "이마의 땀을 닦아주세요",
                "편안하게 쉴 수 있게 도와주세요",
                "부드럽게 격려해주세요",
                "산모가 편한 자세를 찾도록 도와주세요"
            ].randomElement()
        }
    }

    /// 산모를 위한 행동 가이드
    private static func getMotherGuidance(for phase: ContractionPhase) -> String? {
        switch phase {
        case .beforeContraction:
            return nil

        case .contractionStart:
            return [
                "천천히 깊게 숨을 들이마시세요",
                "긴장을 풀고 호흡에 집중하세요",
                "편안한 자세를 찾으세요"
            ].randomElement()

        case .contractionPeak:
            return [
                "계속 천천히 호흡하세요",
                "몸의 힘을 빼고 호흡만 하세요",
                "잘하고 있어요. 호흡에만 집중하세요",
                "긴장을 풀고 숨을 내쉬세요"
            ].randomElement()

        case .contractionEnd:
            return [
                "거의 다 왔어요. 조금만 더요",
                "잘하고 있어요. 곧 끝나요"
            ].randomElement()

        case .restPeriod:
            return [
                "이제 편하게 쉬세요",
                "물을 마시고 힘을 비축하세요",
                "다음 수축까지 충분히 쉬세요",
                "깊게 숨 쉬며 긴장을 푸세요"
            ].randomElement()
        }
    }

    /// 진통 경과 시간에 따른 현재 단계 판단
    static func getCurrentPhase(
        isContracting: Bool,
        elapsedTime: TimeInterval,
        hasRecentContractions: Bool
    ) -> ContractionPhase {
        if !isContracting {
            if hasRecentContractions {
                return .restPeriod
            } else {
                return .beforeContraction
            }
        }

        // 진통 중
        if elapsedTime < 15 {
            return .contractionStart
        } else if elapsedTime < 40 {
            return .contractionPeak
        } else {
            return .contractionEnd
        }
    }

    /// 메시지를 표시할지 여부 판단
    static func shouldShowMessage(for phase: ContractionPhase, elapsedTime: TimeInterval) -> Bool {
        switch phase {
        case .beforeContraction:
            return false

        case .contractionStart:
            // 시작 후 1초에만 표시
            return elapsedTime < 2

        case .contractionPeak:
            // 15초 지점에서만 표시
            return elapsedTime >= 15 && elapsedTime < 17

        case .contractionEnd:
            // 40초 지점에서만 표시
            return elapsedTime >= 40 && elapsedTime < 42

        case .restPeriod:
            // 휴식기 시작 직후에만 표시
            return true
        }
    }
}
