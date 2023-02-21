//
//  SoundView.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/19.
//

import SwiftUI

struct SoundView: View {
    
    @Binding var isSoundViewShow: Bool
    @State var audioPlayer: AVAudioPlayer!
    
    @State var progress: CGFloat = 0.0
    @State private var playing: Bool = true
    @State private var infinite: Bool = true
    @State var duration: Double = 0.0
    @State var formattedDuration: String = ""
    @State var formattedProgress: String = "00:00"
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    isSoundViewShow = false
                    audioPlayer.stop()
                } label: {
                    Image(systemName: "x.square")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            .padding()
            
            
            
            HStack {
                Text(formattedProgress)
                    .font(.caption.monospacedDigit())
                
                // this is a dynamic length progress bar
                GeometryReader { gr in
                    Capsule()
                        .stroke(Color.blue, lineWidth: 2)
                        .background(
                            Capsule()
                                .foregroundColor(Color.blue)
                                .frame(width: gr.size.width * progress,
                                       height: 8), alignment: .leading)
                }
                .frame( height: 8)
                
                Text(formattedDuration)
                    .font(.caption.monospacedDigit())
            }
            
            Spacer()
            
            HStack(alignment: .center, spacing: 20) {
                
                Spacer()
                
                
                Button(action: {
                    if audioPlayer.isPlaying {
                        playing = false
                        audioPlayer.pause()
                    } else if !audioPlayer.isPlaying {
                        playing = true
                        audioPlayer.play()
                    }
                }) {
                    Image(systemName: playing ?
                          "pause.rectangle" : "play.rectangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                }
                
                Button(action: {
                    infinite.toggle()
                    
                    if infinite {
                        AudioManager.shared.player?.numberOfLoops = -1
                    } else {
                        AudioManager.shared.player?.numberOfLoops = 0
                    }
                    
                }) {
                    Image(systemName: infinite ?
                          "repeat.circle" : "repeat.1.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                }
                
                Spacer()
            }
            Spacer()
        }
        .padding()
        .onDisappear {
            audioPlayer.stop()
        }
        .onAppear {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = [ .pad ]
            
            // init audioPlayer
            //let path = Bundle.main.path(forResource: "she", ofType: "m4a")!
            AudioManager.shared.startPlayer(track: "she")
            AudioManager.shared.setupRemoteCommandCenter()
            AudioManager.shared.setupRemoteCommandInfoCenter(track: "she")
            audioPlayer = AudioManager.shared.player
            audioPlayer.prepareToPlay()
            
            
            //I need both! The formattedDuration is the string to display and duration is used when forwarding
            formattedDuration = formatter.string(from: TimeInterval(audioPlayer.duration))!
            duration = audioPlayer.duration
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if !audioPlayer.isPlaying {
                    playing = false
                }
                progress = CGFloat(audioPlayer.currentTime / audioPlayer.duration)
                formattedProgress = formatter.string(from: TimeInterval(audioPlayer.currentTime))!
            }
            audioPlayer.numberOfLoops = -1
        }
    }
}

struct SoundView_Previews: PreviewProvider {
    static var previews: some View {
        SoundView(isSoundViewShow: .constant(true))
    }
}

import AVKit
