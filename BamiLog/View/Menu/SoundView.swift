//
//  SoundView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/19.
//  Updated with modern design system
//

import SwiftUI
import AVFoundation

struct SoundView: View {
    @Binding var isSoundViewShow: Bool
    @State var audioPlayer: AVAudioPlayer?

    @State var progress: CGFloat = 0.0
    @State private var progressTimer: Timer?
    @State private var playing: Bool = true
    @State private var infinite: Bool = true
    @State var duration: Double = 0.0
    @State var formattedDuration: String = ""
    @State var formattedProgress: String = "00:00"

    var body: some View {
        NavigationView {
            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    colors: [
                        Color(red: 0.8, green: 0.7, blue: 0.9),
                        Color(red: 0.7, green: 0.6, blue: 0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: AppSpacing.xxl) {
                    Spacer()

                    // 음악 아이콘
                    VStack(spacing: AppSpacing.lg) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 180, height: 180)

                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 150, height: 150)

                            Image(systemName: "music.note")
                                .font(.system(size: 70, weight: .light))
                                .foregroundColor(.white)
                        }
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)

                        Text("자장가")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // 프로그레스 바
                    VStack(spacing: AppSpacing.md) {
                        HStack {
                            Text(formattedProgress)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .monospacedDigit()

                            Spacer()

                            Text(formattedDuration)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .monospacedDigit()
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // 배경
                                Capsule()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 6)

                                // 진행 바
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * progress, height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    Spacer()

                    // 컨트롤 버튼
                    HStack(spacing: 60) {
                        // 재생/일시정지 버튼
                        Button(action: {
                            guard let player = audioPlayer else { return }
                            if player.isPlaying {
                                playing = false
                                player.pause()
                            } else {
                                playing = true
                                player.play()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

                                Image(systemName: playing ? "pause.fill" : "play.fill")
                                    .font(.system(size: 35, weight: .bold))
                                    .foregroundColor(Color(red: 0.8, green: 0.7, blue: 0.9))
                            }
                        }

                        // 반복 버튼
                        Button(action: {
                            infinite.toggle()

                            if infinite {
                                AudioManager.shared.player?.numberOfLoops = -1
                            } else {
                                AudioManager.shared.player?.numberOfLoops = 0
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(infinite ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color.black.opacity(infinite ? 0.2 : 0.1), radius: 8, x: 0, y: 4)

                                Image(systemName: infinite ? "repeat" : "repeat.1")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(infinite ? Color(red: 0.8, green: 0.7, blue: 0.9) : .white)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, AppSpacing.xxl)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isSoundViewShow = false
                        audioPlayer?.stop()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
        }
        .onDisappear {
            progressTimer?.invalidate()
            progressTimer = nil
            audioPlayer?.stop()
        }
        .onAppear {
            setupAudioPlayer()
        }
    }

    private func setupAudioPlayer() {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]

        // AudioPlayer 초기화
        AudioManager.shared.startPlayer(track: "she")
        AudioManager.shared.setupRemoteCommandCenter()
        AudioManager.shared.setupRemoteCommandInfoCenter(track: "she")
        audioPlayer = AudioManager.shared.player

        guard let player = audioPlayer else { return }
        player.prepareToPlay()

        // 시간 포맷팅
        formattedDuration = formatter.string(from: TimeInterval(player.duration)) ?? "00:00"
        duration = player.duration

        // 타이머 시작
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player = audioPlayer else { return }
            if !player.isPlaying {
                playing = false
            }
            guard player.duration > 0 else { return }
            progress = CGFloat(player.currentTime / player.duration)
            formattedProgress = formatter.string(from: TimeInterval(player.currentTime)) ?? "00:00"
        }

        player.numberOfLoops = -1
    }
}

struct SoundView_Previews: PreviewProvider {
    static var previews: some View {
        SoundView(isSoundViewShow: .constant(true))
    }
}
