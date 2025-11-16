//
//  LogView.swift
//  BamiLog
//
//  Created by Leeo on 11/16/25.
//


import SwiftUI

struct LogView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var contractionManager: ContractionManager
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.15, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // 앱 상태
                        LogSection(title: "앱 상태") {
                            LogItem(label: "현재 페이즈", value: appState.currentPhase.title)
                            LogItem(label: "페이즈 번호", value: "\(appState.currentPhase.rawValue)")
                        }

                        // 진통 통계
                        LogSection(title: "진통 통계") {
                            LogItem(label: "총 진통 횟수", value: "\(contractionManager.contractions.count)회")

                            if let avgInterval = contractionManager.averageInterval {
                                LogItem(label: "평균 간격", value: String(format: "%.2f분", avgInterval))
                            } else {
                                LogItem(label: "평균 간격", value: "데이터 없음")
                            }

                            if let lastInterval = contractionManager.lastInterval {
                                LogItem(label: "최근 간격", value: String(format: "%.2f분", lastInterval / 60))
                            } else {
                                LogItem(label: "최근 간격", value: "데이터 없음")
                            }

                            LogItem(label: "현재 단계", value: contractionManager.currentStage.title)
                        }

                        // 진통 단계 설명
                        LogSection(title: "진통 단계 기준") {
                            VStack(alignment: .leading, spacing: 8) {
                                StageExplanation(stage: "초기 진통기", interval: "5-30분", color: .green)
                                StageExplanation(stage: "활발한 진통기", interval: "3-5분", color: .orange)
                                StageExplanation(stage: "이행기", interval: "1-3분", color: .red)
                            }
                        }

                        // 진통 간격 설명
                        LogSection(title: "진통 간격이란?") {
                            Text("진통 간격은 이전 진통이 시작된 시간부터 다음 진통이 시작된 시간까지의 시간입니다.\n\n예시:\n• 1차 진통 시작: 10:00\n• 2차 진통 시작: 10:07\n• 진통 간격: 7분\n\n간격이 짧아질수록 출산이 가까워진 것입니다.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.8))
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(10)
                        }

                        // 최근 5개 진통 상세
                        if !contractionManager.contractions.isEmpty {
                            LogSection(title: "최근 진통 상세") {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(Array(contractionManager.contractions.prefix(5).enumerated()), id: \.element.id) { index, contraction in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("진통 #\(index + 1)")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.cyan)

                                            LogItem(label: "시작 시간", value: formatDateTime(contraction.timestamp), compact: true)

                                            if let duration = contraction.duration {
                                                LogItem(label: "지속 시간", value: String(format: "%.0f초", duration), compact: true)
                                            }

                                            if index < contractionManager.contractions.count - 1 {
                                                let previous = contractionManager.contractions[index + 1]
                                                let interval = contraction.timestamp.timeIntervalSince(previous.timestamp)
                                                LogItem(label: "이전 진통과 간격", value: String(format: "%.2f분 (%.0f초)", interval / 60, interval), compact: true)
                                            }
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("로그")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
    }

    func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm:ss"
        return formatter.string(from: date)
    }
}

struct LogSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            content
        }
    }
}

struct LogItem: View {
    let label: String
    let value: String
    var compact: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: compact ? 11 : 13))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(size: compact ? 11 : 13, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.vertical, compact ? 2 : 4)
    }
}

struct StageExplanation: View {
    let stage: String
    let interval: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(stage)
                .font(.system(size: 13))
                .foregroundColor(.white)

            Spacer()

            Text(interval)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(color)
        }
    }
}

#Preview {
    LogView()
        .environmentObject(ContractionManager())
        .environmentObject(AppState())
}
