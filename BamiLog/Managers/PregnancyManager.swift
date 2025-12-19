//
//  PregnancyManager.swift
//  BamiLog
//
//  Created by Claude on 12/16/25.
//

import Foundation
import SwiftUI

class PregnancyManager: ObservableObject {
    @Published var pregnancyInfo: PregnancyInfo?
    @Published var checkups: [CheckupSchedule] = []

    private let pregnancyFileURL: URL
    private let checkupsFileURL: URL

    init() {
        pregnancyFileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("pregnancyInfo.json")
        checkupsFileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("checkupSchedules.json")

        loadPregnancyInfo()
        loadCheckups()
    }

    // UserProfile과 동기화
    func syncWithUserProfile(_ userProfile: UserProfile?) {
        // PregnancyInfo가 없는데 UserProfile에 임신 정보가 있으면 동기화
        if pregnancyInfo == nil, let lmpDate = userProfile?.pregnancyStartDate {
            startPregnancy(
                babyName: userProfile?.babyName,
                lastPeriodDate: lmpDate
            )
            print("✅ UserProfile의 임신 정보를 PregnancyManager로 동기화했습니다.")
        }
        // PregnancyInfo는 있는데 UserProfile과 다르면 PregnancyInfo 우선
        else if let pregnancy = pregnancyInfo {
            print("✅ PregnancyInfo 사용 중: \(pregnancy.currentWeek)주 \(pregnancy.currentDay)일")
        }
    }

    // MARK: - 임신 정보 관리

    // 임신 시작 (LMP 기준)
    func startPregnancy(babyName: String? = nil, lastPeriodDate: Date) {
        // 예상 출산일 계산 (LMP + 280일)
        guard let dueDate = Calendar.current.date(
            byAdding: .day, value: 280, to: lastPeriodDate
        ) else { return }

        let (weeks, days) = calculatePregnancyWeeks(from: lastPeriodDate)

        let info = PregnancyInfo(
            babyName: babyName,
            lastPeriodDate: lastPeriodDate,
            expectedDueDate: dueDate,
            currentWeek: weeks,
            currentDay: days
        )

        self.pregnancyInfo = info
        savePregnancyInfo()

        // 기본 검진 일정 자동 생성
        generateDefaultCheckups(lastPeriodDate: lastPeriodDate)
    }

    // 태명 업데이트
    func updateBabyName(_ name: String) {
        guard var info = pregnancyInfo else { return }
        info.babyName = name
        self.pregnancyInfo = info
        savePregnancyInfo()
    }

    // 임신 주차 계산
    func calculatePregnancyWeeks(from lastPeriodDate: Date) -> (weeks: Int, days: Int) {
        let components = Calendar.current.dateComponents(
            [.day],
            from: lastPeriodDate,
            to: Date()
        )

        let totalDays = components.day ?? 0
        let weeks = totalDays / 7
        let days = totalDays % 7

        return (weeks, days)
    }

    // 임신 정보 업데이트 (매일 자동 호출)
    func updatePregnancyInfo() {
        guard let info = pregnancyInfo else { return }

        let (weeks, days) = calculatePregnancyWeeks(from: info.lastPeriodDate)

        var updatedInfo = info
        updatedInfo.currentWeek = weeks
        updatedInfo.currentDay = days

        self.pregnancyInfo = updatedInfo
        savePregnancyInfo()
    }

    // MARK: - 검진 일정 관리

    func addCheckup(_ checkup: CheckupSchedule) {
        checkups.append(checkup)
        checkups.sort { $0.scheduledDate < $1.scheduledDate }
        saveCheckups()
    }

    func updateCheckup(_ checkup: CheckupSchedule) {
        if let index = checkups.firstIndex(where: { $0.id == checkup.id }) {
            checkups[index] = checkup
            saveCheckups()
        }
    }

    func deleteCheckup(_ checkup: CheckupSchedule) {
        checkups.removeAll { $0.id == checkup.id }
        saveCheckups()
    }

    func toggleCheckupCompletion(_ checkup: CheckupSchedule) {
        if let index = checkups.firstIndex(where: { $0.id == checkup.id }) {
            checkups[index].isCompleted.toggle()
            saveCheckups()
        }
    }

    // 기본 검진 일정 생성
    private func generateDefaultCheckups(lastPeriodDate: Date) {
        let defaultCheckups: [(weeks: Int, title: String, type: CheckupType)] = [
            (8, "첫 산전 검진", .regular),
            (12, "기형아 검사 (1차)", .bloodTest),
            (16, "중기 정밀 초음파", .ultrasound),
            (20, "기형아 검사 (2차)", .bloodTest),
            (24, "임신성 당뇨 검사", .glucose),
            (28, "정기 검진", .regular),
            (32, "정기 검진", .regular),
            (36, "출산 준비 검진", .regular),
            (38, "출산 전 최종 검진", .regular)
        ]

        for item in defaultCheckups {
            // 주차를 날짜로 변환
            guard let checkupDate = Calendar.current.date(
                byAdding: .day,
                value: item.weeks * 7,
                to: lastPeriodDate
            ) else { continue }

            // 이미 지난 날짜는 건너뛰기
            if checkupDate < Date() { continue }

            let checkup = CheckupSchedule(
                title: item.title,
                scheduledDate: checkupDate,
                checkupType: item.type
            )

            checkups.append(checkup)
        }

        checkups.sort { $0.scheduledDate < $1.scheduledDate }
        saveCheckups()
    }

    // 다가오는 검진 (7일 이내)
    var upcomingCheckups: [CheckupSchedule] {
        let sevenDaysLater = Calendar.current.date(
            byAdding: .day, value: 7, to: Date()
        ) ?? Date()

        return checkups.filter {
            !$0.isCompleted &&
            $0.scheduledDate >= Date() &&
            $0.scheduledDate <= sevenDaysLater
        }
    }

    // MARK: - 주차별 정보 제공

    // 주차별 태아 발달 정보
    func getFetalDevelopment(week: Int) -> WeeklyFetalDevelopment {
        switch week {
        case 1...4:
            return WeeklyFetalDevelopment(
                week: week,
                title: "임신 초기",
                description: "수정란이 자궁에 착상하여 세포 분열이 시작됩니다.",
                fetalSize: "양귀비씨 크기",
                fetalWeight: "측정 불가",
                keyMilestones: ["수정란 착상", "세포 분열 시작"],
                icon: "circle.fill"
            )
        case 5...8:
            return WeeklyFetalDevelopment(
                week: week,
                title: "배아기",
                description: "심장이 뛰기 시작하고 주요 장기가 형성됩니다.",
                fetalSize: "블루베리 크기",
                fetalWeight: "약 1g",
                keyMilestones: ["심장 박동 시작", "팔다리 형성", "신경관 발달"],
                icon: "heart.fill"
            )
        case 9...12:
            return WeeklyFetalDevelopment(
                week: week,
                title: "태아기 진입",
                description: "손가락과 발가락이 구분되고 얼굴 형태가 갖춰집니다.",
                fetalSize: "자두 크기",
                fetalWeight: "약 14g",
                keyMilestones: ["손발가락 분리", "얼굴 형성", "생식기 발달"],
                icon: "figure.wave"
            )
        case 13...16:
            return WeeklyFetalDevelopment(
                week: week,
                title: "임신 중기 시작",
                description: "태아가 움직이기 시작하며 뼈가 단단해집니다.",
                fetalSize: "아보카도 크기",
                fetalWeight: "약 100g",
                keyMilestones: ["태동 시작", "뼈 형성", "청각 발달"],
                icon: "ear"
            )
        case 17...20:
            return WeeklyFetalDevelopment(
                week: week,
                title: "성별 확인 가능",
                description: "초음파로 성별을 확인할 수 있으며 태동이 활발합니다.",
                fetalSize: "바나나 크기",
                fetalWeight: "약 300g",
                keyMilestones: ["성별 확인 가능", "태지 형성", "청각 발달"],
                icon: "waveform.path.ecg"
            )
        case 21...24:
            return WeeklyFetalDevelopment(
                week: week,
                title: "생존 가능성 증가",
                description: "폐가 발달하여 생존 가능성이 높아집니다.",
                fetalSize: "옥수수 크기",
                fetalWeight: "약 600g",
                keyMilestones: ["폐 발달", "눈꺼풀 열림", "수면 패턴 형성"],
                icon: "lungs.fill"
            )
        case 25...28:
            return WeeklyFetalDevelopment(
                week: week,
                title: "뇌 발달 급증",
                description: "뇌가 빠르게 발달하며 눈을 뜰 수 있습니다.",
                fetalSize: "양배추 크기",
                fetalWeight: "약 1kg",
                keyMilestones: ["뇌 발달 급증", "눈을 뜸", "규칙적 수면"],
                icon: "brain.head.profile"
            )
        case 29...32:
            return WeeklyFetalDevelopment(
                week: week,
                title: "체중 증가 시기",
                description: "급격한 체중 증가와 함께 모든 장기가 성숙합니다.",
                fetalSize: "파인애플 크기",
                fetalWeight: "약 1.7kg",
                keyMilestones: ["체중 급증", "면역체계 발달", "꿈을 꿈"],
                icon: "scalemass.fill"
            )
        case 33...36:
            return WeeklyFetalDevelopment(
                week: week,
                title: "출산 준비",
                description: "두개골이 부드러워지고 출산을 위한 준비를 합니다.",
                fetalSize: "로메인 상추 크기",
                fetalWeight: "약 2.5kg",
                keyMilestones: ["두개골 유연화", "머리가 골반으로", "폐 성숙"],
                icon: "figure.stand"
            )
        case 37...42:
            return WeeklyFetalDevelopment(
                week: week,
                title: "만삭",
                description: "언제든 출산할 수 있는 상태입니다.",
                fetalSize: "수박 크기",
                fetalWeight: "약 3-3.5kg",
                keyMilestones: ["만삭", "출산 준비 완료"],
                icon: "checkmark.circle.fill"
            )
        default:
            return WeeklyFetalDevelopment(
                week: week,
                title: "\(week)주차",
                description: "태아가 건강하게 자라고 있습니다.",
                fetalSize: "정보 없음",
                fetalWeight: "정보 없음",
                keyMilestones: [],
                icon: "star.fill"
            )
        }
    }

    // 주차별 산모 건강 가이드
    func getMotherGuide(week: Int) -> WeeklyMotherGuide {
        switch week {
        case 1...12:
            return WeeklyMotherGuide(
                week: week,
                title: "임신 초기 (1분기)",
                tips: [
                    "엽산 보충제를 매일 복용하세요",
                    "충분한 수분을 섭취하세요",
                    "카페인 섭취를 줄이세요",
                    "충분한 휴식을 취하세요"
                ],
                warnings: [
                    "출혈이나 심한 복통이 있으면 즉시 병원을 방문하세요",
                    "날 음식이나 덜 익은 음식은 피하세요",
                    "무거운 물건을 들지 마세요"
                ],
                commonSymptoms: ["입덧", "피로", "가슴 통증", "빈뇨"]
            )
        case 13...27:
            return WeeklyMotherGuide(
                week: week,
                title: "임신 중기 (2분기)",
                tips: [
                    "태교를 시작하기 좋은 시기입니다",
                    "적절한 운동으로 체력을 유지하세요",
                    "철분 보충에 신경 쓰세요",
                    "골반 근육 운동을 시작하세요"
                ],
                warnings: [
                    "조기 진통 증상에 주의하세요",
                    "과도한 체중 증가를 피하세요",
                    "당뇨 검사를 받으세요"
                ],
                commonSymptoms: ["요통", "다리 부종", "피부 변화", "치통"]
            )
        case 28...42:
            return WeeklyMotherGuide(
                week: week,
                title: "임신 후기 (3분기)",
                tips: [
                    "출산 준비물을 미리 챙기세요",
                    "호흡법을 연습하세요",
                    "충분한 휴식을 취하세요",
                    "출산 신호를 숙지하세요"
                ],
                warnings: [
                    "진통이 규칙적이면 병원에 연락하세요",
                    "양수가 터지면 즉시 병원으로 가세요",
                    "태동이 줄어들면 즉시 병원에 연락하세요"
                ],
                commonSymptoms: ["잦은 소변", "숨가쁨", "불면증", "부종"]
            )
        default:
            return WeeklyMotherGuide(
                week: week,
                title: "\(week)주차",
                tips: [],
                warnings: [],
                commonSymptoms: []
            )
        }
    }

    // 주차별 아빠 가이드
    func getFatherGuide(week: Int) -> WeeklyFatherGuide {
        switch week {
        case 1...12:
            return WeeklyFatherGuide(
                week: week,
                title: "임신 초기 - 아빠의 역할",
                whatToDo: [
                    "산부인과 검진에 함께 가주세요",
                    "입덧으로 힘들어하는 아내를 위해 식사 준비를 도와주세요",
                    "임신 관련 서적을 함께 읽으며 공부하세요",
                    "아내의 감정 변화를 이해하고 공감해주세요"
                ],
                emotionalSupport: [
                    "\"힘들지? 내가 도와줄게\" - 적극적으로 도움 의사를 표현하세요",
                    "\"우리 아기가 잘 자라고 있어\" - 긍정적인 말로 안심시켜 주세요",
                    "작은 변화도 알아차리고 칭찬해주세요"
                ],
                practicalHelp: [
                    "무거운 물건 들기, 높은 곳의 물건 내리기 등 대신해주세요",
                    "집안일을 적극적으로 분담하세요",
                    "엽산 보충제 챙겨주기"
                ]
            )
        case 13...20:
            return WeeklyFatherGuide(
                week: week,
                title: "임신 중기 전반 - 아빠의 역할",
                whatToDo: [
                    "초음파 검사에 함께 가서 아기를 확인하세요",
                    "태교에 적극 참여하세요 (음악 들려주기, 책 읽어주기)",
                    "아내와 산책하며 대화 시간을 가지세요",
                    "출산 준비 교실에 함께 등록하세요"
                ],
                emotionalSupport: [
                    "배를 쓰다듬으며 아기에게 말을 걸어주세요",
                    "아내의 외모 변화에 대해 긍정적으로 말해주세요",
                    "\"당신도 아기도 사랑해\" 자주 표현하세요"
                ],
                practicalHelp: [
                    "아내가 편하게 쉴 수 있는 환경 만들기",
                    "마사지해주기 (발, 어깨, 허리)",
                    "건강한 간식 준비해주기"
                ]
            )
        case 21...28:
            return WeeklyFatherGuide(
                week: week,
                title: "임신 중기 후반 - 아빠의 역할",
                whatToDo: [
                    "태동을 느껴보세요 - 배에 손을 대고 아기와 교감하세요",
                    "육아 용품 리스트를 함께 작성하세요",
                    "출산 및 육아 교실에 참여하세요",
                    "아내의 취미 활동을 지원해주세요"
                ],
                emotionalSupport: [
                    "아기 이름을 함께 고민하세요",
                    "\"힘들 때 언제든 말해\" 항상 지지해주세요",
                    "태동을 함께 느끼며 기쁨을 나누세요"
                ],
                practicalHelp: [
                    "아기 방 준비 시작하기",
                    "출산 준비물 함께 쇼핑하기",
                    "병원까지 가는 경로 미리 확인하기"
                ]
            )
        case 29...36:
            return WeeklyFatherGuide(
                week: week,
                title: "임신 후기 - 출산 준비",
                whatToDo: [
                    "출산 가방을 함께 준비하세요",
                    "진통 시작 시 대처 방법을 숙지하세요",
                    "병원까지 가는 여러 경로를 파악하세요",
                    "육아 휴직이나 업무 조정을 미리 계획하세요"
                ],
                emotionalSupport: [
                    "\"당신은 훌륭한 엄마가 될 거야\" 격려해주세요",
                    "출산에 대한 두려움을 함께 이야기하세요",
                    "\"내가 항상 곁에 있을게\" 안심시켜 주세요"
                ],
                practicalHelp: [
                    "출산 준비물 최종 점검",
                    "집안을 미리 정리하고 청소하기",
                    "냉동 음식 준비해두기",
                    "24시간 연락 가능한 상태 유지"
                ]
            )
        case 37...42:
            return WeeklyFatherGuide(
                week: week,
                title: "만삭 - 언제든 준비 완료",
                whatToDo: [
                    "진통 신호를 숙지하고 즉시 대응할 준비를 하세요",
                    "항상 전화를 받을 수 있게 하세요",
                    "차에 기름을 가득 채워두세요",
                    "출산 시 분만실 동행 준비를 하세요"
                ],
                emotionalSupport: [
                    "\"조금만 더 힘내, 곧 만날 수 있어\" 응원하세요",
                    "불안해하는 아내를 안심시켜 주세요",
                    "\"당신이 대단해, 자랑스러워\" 감사 표현하기"
                ],
                practicalHelp: [
                    "언제든 출발할 수 있도록 준비",
                    "진통 시간 재는 앱 다운로드",
                    "병원 연락처 즉시 확인 가능하게",
                    "산후조리원 예약 최종 확인"
                ]
            )
        default:
            return WeeklyFatherGuide(
                week: week,
                title: "아빠의 역할",
                whatToDo: [],
                emotionalSupport: [],
                practicalHelp: []
            )
        }
    }

    // MARK: - 데이터 저장/로드

    private func savePregnancyInfo() {
        guard let info = pregnancyInfo else { return }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(info)
            try data.write(to: pregnancyFileURL)
        } catch {
            print("Failed to save pregnancy info: \(error)")
        }
    }

    private func loadPregnancyInfo() {
        do {
            let data = try Data(contentsOf: pregnancyFileURL)
            let decoder = JSONDecoder()
            let loadedInfo = try decoder.decode(PregnancyInfo.self, from: data)
            self.pregnancyInfo = loadedInfo

            // 로드 시 현재 주차 업데이트
            updatePregnancyInfo()
        } catch {
            print("No pregnancy info found or failed to load: \(error)")
        }
    }

    private func saveCheckups() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(checkups)
            try data.write(to: checkupsFileURL)
        } catch {
            print("Failed to save checkups: \(error)")
        }
    }

    private func loadCheckups() {
        do {
            let data = try Data(contentsOf: checkupsFileURL)
            let decoder = JSONDecoder()
            let loadedCheckups = try decoder.decode([CheckupSchedule].self, from: data)
            self.checkups = loadedCheckups.sorted { $0.scheduledDate < $1.scheduledDate }
        } catch {
            print("No checkups found or failed to load: \(error)")
        }
    }
}
