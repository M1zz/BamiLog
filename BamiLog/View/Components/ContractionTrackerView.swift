//
//  ContractionTrackerView.swift
//  BamiLog
//
//  Created by Leeo on 11/16/25.
//


import SwiftUI

struct ContractionTrackerView: View {
    @EnvironmentObject var contractionManager: ContractionManager
    @State private var isShowingHistory = false
    @State private var showDeleteAlert = false
    @State private var currentDuration: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        NavigationView {
            ZStack {
                // 배경 - 회색
                Color(red: 0.95, green: 0.95, blue: 0.95)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // 진통 단계 카드
                        StageCard(stage: contractionManager.currentStage)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                        // 통계 카드
                        if contractionManager.contractions.count >= 2 {
                            StatisticsCard(
                                averageInterval: contractionManager.averageInterval,
                                lastInterval: contractionManager.lastInterval
                            )
                            .padding(.horizontal, 16)
                        }

                        // 진통 기록 버튼 영역
                        if contractionManager.isContractionInProgress {
                            // 진통 진행 중 - 타이머와 버튼들
                            VStack(spacing: 12) {
                                // 타이머 표시
                                VStack(spacing: 8) {
                                    Text("진통 진행 중")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppColors.textSecondary)

                                    Text(formatDuration(currentDuration))
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.orange)
                                        .monospacedDigit()
                                }
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                                .background(AppColors.cardBackground)
                                .cornerRadius(14)

                                // 버튼들
                                HStack(spacing: 12) {
                                    // 취소 버튼
                                    Button(action: {
                                        stopTimer()
                                        contractionManager.cancelContraction()
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 20))
                                            Text("취소")
                                                .font(.system(size: 18, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.red.opacity(0.8))
                                        .cornerRadius(12)
                                    }

                                    // 종료 버튼
                                    Button(action: {
                                        stopTimer()
                                        contractionManager.endContraction()
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                            Text("진통 종료")
                                                .font(.system(size: 18, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.green, Color.green.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        } else {
                            // 진통 시작 버튼
                            Button(action: {
                                contractionManager.startContraction()
                                startTimer()
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                    Text("진통 시작")
                                        .font(.system(size: 20, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal, 16)
                        }

                        // 최근 진통 목록
                        if !contractionManager.contractions.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                // 전체 과정 요약 바 (최근 진통 위쪽)
                                ContractionSummaryBar(contractions: contractionManager.contractions)
                                    .padding(.horizontal, 16)

                                HStack {
                                    Text("최근 진통")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(AppColors.textPrimary)

                                    Spacer()

                                    Button(action: {
                                        isShowingHistory = true
                                    }) {
                                        Text("전체 보기")
                                            .font(.system(size: 13))
                                            .foregroundColor(.cyan)
                                    }
                                }
                                .padding(.horizontal, 16)

                                ForEach(Array(contractionManager.contractions.prefix(5).enumerated()), id: \.element.id) { index, contraction in
                                    ContractionRow(
                                        contraction: contraction,
                                        previousContraction: index < contractionManager.contractions.count - 1 ? contractionManager.contractions[index + 1] : nil
                                    )
                                    .padding(.horizontal, 16)
                                }
                            }
                        } else {
                            // 빈 상태
                            VStack(spacing: 12) {
                                Image(systemName: "heart.text.square")
                                    .font(.system(size: 50))
                                    .foregroundColor(AppColors.textSecondary.opacity(0.5))

                                Text("아직 기록된 진통이 없습니다")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textSecondary)

                                Text("진통이 시작되면 위 버튼을 눌러주세요")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                            .padding(.top, 20)
                        }

                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingHistory) {
                ContractionHistoryView()
                    .environmentObject(contractionManager)
            }
            .alert("모든 진통 기록 삭제", isPresented: $showDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    contractionManager.deleteAllContractions()
                }
            } message: {
                Text("모든 진통 기록을 삭제하시겠습니까?")
            }
            .onAppear {
                // 앱 시작 시 진통이 진행 중이었다면 타이머 재시작
                if contractionManager.isContractionInProgress {
                    startTimer()
                }
            }
            .onDisappear {
                stopTimer()
            }
        }
    }

    // 타이머 시작
    private func startTimer() {
        currentDuration = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = contractionManager.contractionStartTime {
                currentDuration = Date().timeIntervalSince(startTime)
            }
        }
    }

    // 타이머 중지
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        currentDuration = 0
    }

    // 시간 포맷팅
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// 진통 단계 카드
struct StageCard: View {
    let stage: LaborStage

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: stage == .none ? "moon.stars" : "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(stage.color)

                Text(stage.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()
            }

            Text(stage.description)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(stage.color.opacity(0.3), lineWidth: 2)
        )
    }
}

// 통계 카드
struct StatisticsCard: View {
    let averageInterval: Double?
    let lastInterval: TimeInterval?
    var userRole: UserRole = .firstTimeMother // 기본값: 초산모

    // 간격 변화량 계산
    var intervalChange: Double? {
        guard let avg = averageInterval, let last = lastInterval else { return nil }
        return (last / 60) - avg // 분 단위로 변환하여 차이 계산
    }

    // 간격 변화 텍스트
    var changeText: String {
        guard let change = intervalChange else { return "" }
        let absChange = abs(change)
        if change < -0.5 {
            return String(format: "%.1f분 감소", absChange)
        } else if change > 0.5 {
            return String(format: "%.1f분 증가", absChange)
        } else {
            return "유지"
        }
    }

    // 간격 변화 색상
    var changeColor: Color {
        guard let change = intervalChange else { return .gray }
        if change < -0.5 {
            return .red // 간격이 줄어들고 있음 (주의)
        } else if change > 0.5 {
            return .green // 간격이 늘어남 (안정)
        } else {
            return .orange // 유지
        }
    }

    // 역할별 행동 가이드
    var actionGuide: (text: String, color: Color, icon: String)? {
        guard let last = lastInterval else { return nil }
        let minutes = last / 60

        // 초산모 기준
        if userRole == .firstTimeMother {
            if minutes <= 5 {
                return ("즉시 병원으로 출발하세요!", Color(red: 0.9, green: 0.2, blue: 0.2), "exclamationmark.triangle.fill")
            } else if minutes <= 10 {
                return ("병원 갈 준비를 시작하세요", Color(red: 1.0, green: 0.5, blue: 0.0), "car.fill")
            } else if minutes <= 15 {
                return ("병원에 연락하고 준비하세요", Color(red: 1.0, green: 0.7, blue: 0.0), "phone.fill")
            } else if minutes <= 20 {
                return ("진통 간격을 계속 기록하세요", Color(red: 0.3, green: 0.6, blue: 1.0), "clock.fill")
            } else {
                return ("규칙적인 진통인지 확인하세요", Color(red: 0.5, green: 0.5, blue: 0.5), "checkmark.circle.fill")
            }
        }
        // 경산모 기준 (더 빠르게 진행됨!)
        else if userRole == .experiencedMother {
            if minutes <= 5 {
                return ("즉시 병원으로 출발하세요!", Color(red: 0.9, green: 0.2, blue: 0.2), "exclamationmark.triangle.fill")
            } else if minutes <= 10 {
                return ("즉시 병원으로 출발하세요!", Color(red: 0.9, green: 0.2, blue: 0.2), "exclamationmark.triangle.fill")
            } else if minutes <= 15 {
                return ("지금 바로 병원 가세요! (경산모)", Color(red: 0.9, green: 0.3, blue: 0.2), "car.fill")
            } else if minutes <= 20 {
                return ("병원 갈 준비를 하세요", Color(red: 1.0, green: 0.5, blue: 0.0), "phone.fill")
            } else {
                return ("진통이 빨리 진행될 수 있습니다", Color(red: 1.0, green: 0.7, blue: 0.0), "clock.fill")
            }
        }
        // 아빠 기준 (경산모 기준 따름 - 안전하게)
        else {
            if minutes <= 5 {
                return ("즉시 병원으로 출발하세요!", Color(red: 0.9, green: 0.2, blue: 0.2), "exclamationmark.triangle.fill")
            } else if minutes <= 10 {
                return ("병원 갈 준비를 시작하세요", Color(red: 1.0, green: 0.5, blue: 0.0), "car.fill")
            } else if minutes <= 15 {
                return ("병원에 연락하고 준비하세요", Color(red: 1.0, green: 0.7, blue: 0.0), "phone.fill")
            } else if minutes <= 20 {
                return ("진통 간격을 계속 기록하세요", Color(red: 0.3, green: 0.6, blue: 1.0), "clock.fill")
            } else {
                return ("규칙적인 진통인지 확인하세요", Color(red: 0.5, green: 0.5, blue: 0.5), "checkmark.circle.fill")
            }
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // 간격 정보
            HStack(spacing: 16) {
                // 평균 간격
                VStack(spacing: 4) {
                    Text("평균 간격")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)

                    Text(averageInterval.map { formatInterval($0 * 60) } ?? "-")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.cyan)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 40)
                    .background(AppColors.textSecondary.opacity(0.3))

                // 최근 간격
                VStack(spacing: 4) {
                    Text("최근 간격")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)

                    Text(lastInterval.map { formatInterval($0) } ?? "-")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.blue)

                    // 변화량 표시
                    if intervalChange != nil {
                        HStack(spacing: 3) {
                            Image(systemName: (intervalChange ?? 0) < 0 ? "arrow.down" : (intervalChange ?? 0) > 0 ? "arrow.up" : "minus")
                                .font(.system(size: 9))
                            Text(changeText)
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(changeColor)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // 행동 가이드
            if let guide = actionGuide {
                Divider()
                    .background(AppColors.textSecondary.opacity(0.2))

                HStack(spacing: 10) {
                    Image(systemName: guide.icon)
                        .font(.system(size: 16))
                        .foregroundColor(guide.color)

                    Text(guide.text)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(guide.color)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            } else {
                Spacer()
                    .frame(height: 4)
            }
        }
        .background(AppColors.cardBackground)
        .cornerRadius(14)
    }

    func formatInterval(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        if minutes > 0 {
            return String(format: "%d분 %02d초", minutes, seconds)
        } else {
            return String(format: "%d초", seconds)
        }
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

// 진통 행
struct ContractionRow: View {
    let contraction: Contraction
    let previousContraction: Contraction?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                // 왼쪽: 주기와 진통을 세로로
                VStack(alignment: .leading, spacing: 8) {
                    // 1. 진통 간격
                    if let previous = previousContraction {
                        let interval = contraction.timestamp.timeIntervalSince(previous.timestamp)
                        HStack(spacing: 5) {
                            Text("휴식")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.cyan.opacity(0.8))
                            Text(formatInterval(interval))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.cyan)
                        }
                    } else {
                        HStack(spacing: 5) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                            Text("첫 진통")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.yellow)
                    }

                    // 2. 지속 시간
                    if let duration = contraction.duration {
                        HStack(spacing: 5) {
                            Text("진통")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.orange.opacity(0.8))
                            Text(formatDuration(duration))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.orange)
                        }
                    }
                }

                Spacer()

                // 오른쪽: 통증
                if let painLevel = contraction.painLevel {
                    HStack(spacing: 5) {
                        Text("통증")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.red.opacity(0.8))
                        Text("\(painLevel)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red)
                    }
                }
            }

            // 시간 (오른쪽 아래)
            HStack {
                Spacer()
                Text(formattedTime(contraction.timestamp))
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func formatInterval(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        if minutes > 0 {
            return String(format: "%d분 %02d초", minutes, seconds)
        } else {
            return String(format: "%d초", seconds)
        }
    }

    func formatDuration(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        if minutes > 0 {
            return String(format: "%d분 %02d초", minutes, seconds)
        } else {
            return String(format: "%d초", seconds)
        }
    }
}

// 전체 과정 요약 바 - 시각적 스택 차트
struct ContractionSummaryBar: View {
    let contractions: [Contraction]

    // 차트 세그먼트 데이터
    struct ChartSegment: Identifiable {
        let id = UUID()
        let type: SegmentType
        let minutes: Double
        let color: Color

        enum SegmentType {
            case duration
            case interval
        }
    }

    var chartSegments: [ChartSegment] {
        let recentContractions = Array(contractions.prefix(5).reversed()) // 시간 순서대로
        var segments: [ChartSegment] = []

        for (index, contraction) in recentContractions.enumerated() {
            // 길이 추가
            if let duration = contraction.duration {
                segments.append(ChartSegment(
                    type: .duration,
                    minutes: duration / 60,
                    color: .orange
                ))
            }

            // 간격 추가 (다음 진통과의 간격)
            if index < recentContractions.count - 1 {
                let nextContraction = recentContractions[index + 1]
                let interval = nextContraction.timestamp.timeIntervalSince(contraction.timestamp)
                segments.append(ChartSegment(
                    type: .interval,
                    minutes: interval / 60,
                    color: .cyan
                ))
            }
        }

        return segments
    }

    var totalMinutes: Double {
        chartSegments.reduce(0) { $0 + $1.minutes }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 제목과 범례
            HStack {
                Text("진통 패턴")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                // 범례
                HStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Circle()
                            .fill(.orange)
                            .frame(width: 6, height: 6)
                        Text("진통")
                            .font(.system(size: 10))
                            .foregroundColor(.orange.opacity(0.8))
                    }
                    HStack(spacing: 3) {
                        Circle()
                            .fill(.cyan)
                            .frame(width: 6, height: 6)
                        Text("휴식")
                            .font(.system(size: 10))
                            .foregroundColor(.cyan.opacity(0.8))
                    }
                }
            }

            // 스택 차트
            if !chartSegments.isEmpty && totalMinutes > 0 {
                VStack(spacing: 4) {
                    // 시간 레이블
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            ForEach(chartSegments) { segment in
                                let width = geometry.size.width * (segment.minutes / totalMinutes)

                                // 폭이 30pt 이상일 때만 숫자 표시
                                if width >= 30 {
                                    Text(String(format: "%.0f", segment.minutes))
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(segment.color)
                                        .frame(width: width)
                                } else {
                                    Text("")
                                        .frame(width: width)
                                }
                            }
                        }
                    }
                    .frame(height: 18)

                    // 차트 바
                    GeometryReader { geometry in
                        HStack(spacing: 2) {
                            ForEach(chartSegments) { segment in
                                let width = geometry.size.width * (segment.minutes / totalMinutes)

                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [segment.color, segment.color.opacity(0.7)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: max(width - 2, 0))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .frame(height: 28)

                    // 단위 표시
                    Text("(분)")
                        .font(.system(size: 9))
                        .foregroundColor(AppColors.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            } else {
                Text("진통 기록이 충분하지 않습니다")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.vertical, 8)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .cornerRadius(12)
    }
}

#Preview {
    ContractionTrackerView()
        .environmentObject(ContractionManager())
}
