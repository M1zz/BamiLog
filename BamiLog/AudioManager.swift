//
//  AudioManager.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/02/21.
//

import Foundation
import MediaPlayer
import AVKit

final class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    var player: AVAudioPlayer?
    
    func startPlayer(track: String, isPreview: Bool = false) {
        guard let url = Bundle.main.url(forResource: track, withExtension: "m4a") else {
            print("Resource not found: \(track)")
            return
        }
        
        do {
            //try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowAirPlay, .allowBluetoothA2DP])
        
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            
            if isPreview {
                player?.prepareToPlay()
            } else {
                player?.play()
            }
        } catch {
            print("Fail to initialize player", error)
        }
    }
    
    func setupRemoteCommandInfoCenter(track: String) {
        let center = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = center.nowPlayingInfo ?? [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = track
        if let albumCoverPage = UIImage(named: track) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: albumCoverPage.size, requestHandler: { size in
                return albumCoverPage
            })
        }
        
        center.nowPlayingInfo = nowPlayingInfo
    }
    
    func setupRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.removeTarget(nil)
        center.pauseCommand.removeTarget(nil)
        center.nextTrackCommand.removeTarget(nil)
        center.previousTrackCommand.removeTarget(nil)
        //guard let mixedSound = self.mixedSound else { return }

        center.playCommand.addTarget { commandEvent -> MPRemoteCommandHandlerStatus in
            self.player?.play()
            return .success
        }

        center.pauseCommand.addTarget { commandEvent -> MPRemoteCommandHandlerStatus in
            self.player?.pause()
            return .success
        }

//        center.nextTrackCommand.addTarget { MPRemoteCommandEvent in
//            self.setupNextTrack(mixedSound: mixedSound)
//            return .success
//        }
//
//        center.previousTrackCommand.addTarget { MPRemoteCommandEvent in
//            self.setupPreviousTrack(mixedSound: mixedSound)
//            return .success
//        }
    }
}
