//
//  MenstrualCycleManager.swift
//  BamiLog
//
//  Created by Claude on 12/16/25.
//

import Foundation
import SwiftUI

class MenstrualCycleManager: ObservableObject {
    @Published var cycles: [MenstrualCycle] = []
    @Published var currentCycle: MenstrualCycle?
    @Published var symptoms: [Symptom] = []

    private let cyclesFileURL: URL

    init() {
        cyclesFileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("menstrualCycles.json")
        loadCycles()
    }

    // MARK: - 생리 주기 관리

    // 생리 시작
    func startPeriod(startDate: Date = Date()) {
        // 이전 주기가 진행 중이면 종료
        if let ongoing = currentCycle {
            endPeriod(cycle: ongoing, endDate: startDate)
        }

        let newCycle = MenstrualCycle(
            id: UUID(),
            startDate: startDate,
            endDate: nil,
            cycleLength: nil,
            periodLength: nil,
            dailyLogs: [],
            notes: nil
        )

        currentCycle = newCycle
        cycles.insert(newCycle, at: 0)
        saveCycles()
    }

    // 생리 종료
    func endPeriod(cycle: MenstrualCycle, endDate: Date = Date()) {
        guard let index = cycles.firstIndex(where: { $0.id == cycle.id }) else { return }

        let periodLength = Calendar.current.dateComponents([.day],
                                                           from: cycle.startDate, to: endDate).day ?? 0

        var updatedCycle = cycle
        updatedCycle.endDate = endDate
        updatedCycle.periodLength = periodLength

        // 이전 주기가 있으면 주기 길이 계산
        if cycles.count > 1 {
            // 이전 주기 찾기 (현재 주기 제외)
            let otherCycles = cycles.filter { $0.id != cycle.id }
            if let previousCycle = otherCycles.first {
                let cycleLength = Calendar.current.dateComponents([.day],
                                                                  from: previousCycle.startDate, to: cycle.startDate).day ?? 0
                updatedCycle.cycleLength = cycleLength
            }
        }

        cycles[index] = updatedCycle
        currentCycle = nil
        saveCycles()
    }

    // MARK: - 일별 로그 관리

    func addDailyLog(date: Date, flowLevel: FlowLevel? = nil, symptoms: [Symptom] = [], notes: String? = nil) {
        guard let current = currentCycle,
              let index = cycles.firstIndex(where: { $0.id == current.id }) else { return }

        var updatedCycle = cycles[index]

        // 같은 날짜의 로그가 있으면 업데이트, 없으면 새로 추가
        if let logIndex = updatedCycle.dailyLogs.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }) {
            var existingLog = updatedCycle.dailyLogs[logIndex]
            if let flowLevel = flowLevel {
                existingLog.flowLevel = flowLevel
            }
            existingLog.symptoms.append(contentsOf: symptoms)
            if let notes = notes {
                existingLog.notes = notes
            }
            updatedCycle.dailyLogs[logIndex] = existingLog
        } else {
            let newLog = DailyLog(date: date, flowLevel: flowLevel, symptoms: symptoms, notes: notes)
            updatedCycle.dailyLogs.append(newLog)
        }

        cycles[index] = updatedCycle
        currentCycle = updatedCycle
        saveCycles()
    }

    func updateFlowLevel(date: Date, flowLevel: FlowLevel) {
        addDailyLog(date: date, flowLevel: flowLevel)
    }

    // MARK: - 증상 관리

    func addSymptom(date: Date = Date(), type: SymptomType, severity: Int) {
        let symptom = Symptom(type: type, severity: severity, date: date)

        // 현재 주기에 증상 추가
        if let current = currentCycle,
           let index = cycles.firstIndex(where: { $0.id == current.id }) {
            addDailyLog(date: date, symptoms: [symptom])
        }

        symptoms.append(symptom)
        saveCycles()
    }

    func deleteSymptom(_ symptom: Symptom) {
        symptoms.removeAll { $0.id == symptom.id }

        // 주기에서도 제거
        for i in 0..<cycles.count {
            for j in 0..<cycles[i].dailyLogs.count {
                cycles[i].dailyLogs[j].symptoms.removeAll { $0.id == symptom.id }
            }
        }

        saveCycles()
    }

    // 특정 날짜의 데이터 가져오기
    func getDataForDate(_ date: Date) -> (flowLevel: FlowLevel?, symptoms: [Symptom], notes: String?) {
        // 모든 주기에서 해당 날짜 찾기
        for cycle in cycles {
            if let log = cycle.dailyLogs.first(where: {
                Calendar.current.isDate($0.date, inSameDayAs: date)
            }) {
                return (log.flowLevel, log.symptoms, log.notes)
            }
        }
        return (nil, [], nil)
    }

    // MARK: - 통계 및 예측

    // 평균 주기 계산
    var averageCycleLength: Int? {
        let cycleLengths = cycles.compactMap { $0.cycleLength }
        guard cycleLengths.count >= 2 else { return nil }
        return cycleLengths.reduce(0, +) / cycleLengths.count
    }

    // 평균 생리 기간
    var averagePeriodLength: Int? {
        let periodLengths = cycles.compactMap { $0.periodLength }
        guard periodLengths.count >= 2 else { return nil }
        return periodLengths.reduce(0, +) / periodLengths.count
    }

    // 다음 생리 예측
    var nextPeriodPrediction: Date? {
        guard let lastCycle = cycles.first,
              let avgLength = averageCycleLength else { return nil }

        return Calendar.current.date(byAdding: .day, value: avgLength,
                                     to: lastCycle.startDate)
    }

    // 배란일 예측
    func predictOvulation() -> OvulationPrediction? {
        guard let avgLength = averageCycleLength,
              let lastCycle = cycles.first else { return nil }

        // 일반적으로 생리 시작 14일 전에 배란
        let ovulationDay = avgLength - 14

        guard let ovulationDate = Calendar.current.date(
            byAdding: .day, value: ovulationDay, to: lastCycle.startDate
        ) else { return nil }

        // 가임기: 배란일 5일 전 ~ 배란일 1일 후
        guard let fertileStart = Calendar.current.date(
            byAdding: .day, value: -5, to: ovulationDate
        ),
        let fertileEnd = Calendar.current.date(
            byAdding: .day, value: 1, to: ovulationDate
        ) else { return nil }

        // 주기 데이터가 많을수록 신뢰도 높음
        let confidence = min(Double(cycles.count) / 6.0, 1.0)

        return OvulationPrediction(
            predictedOvulationDate: ovulationDate,
            fertileWindowStart: fertileStart,
            fertileWindowEnd: fertileEnd,
            confidence: confidence
        )
    }

    // MARK: - 데이터 저장/로드

    private func saveCycles() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(cycles)
            try data.write(to: cyclesFileURL)
        } catch {
            print("Failed to save menstrual cycles: \(error)")
        }
    }

    private func loadCycles() {
        do {
            let data = try Data(contentsOf: cyclesFileURL)
            let decoder = JSONDecoder()
            let loadedCycles = try decoder.decode([MenstrualCycle].self, from: data)
            cycles = loadedCycles.sorted { $0.startDate > $1.startDate }

            // 진행 중인 주기 찾기
            currentCycle = cycles.first { $0.isOngoing }

            // 모든 증상 수집
            symptoms = cycles.flatMap { $0.allSymptoms }.sorted { $0.date > $1.date }
        } catch {
            print("No menstrual cycles found or failed to load: \(error)")
        }
    }

    func deleteCycle(_ cycle: MenstrualCycle) {
        cycles.removeAll { $0.id == cycle.id }
        if currentCycle?.id == cycle.id {
            currentCycle = nil
        }
        saveCycles()
    }

    func deleteAllCycles() {
        cycles.removeAll()
        currentCycle = nil
        symptoms.removeAll()

        do {
            try FileManager.default.removeItem(at: cyclesFileURL)
        } catch {
            print("Failed to delete cycles file: \(error)")
        }
    }
}
