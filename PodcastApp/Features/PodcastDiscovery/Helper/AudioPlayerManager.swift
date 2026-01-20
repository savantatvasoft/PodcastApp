//
//  AudioPlayerManager.swift
//  PodcastApp
//
//  Created by MACM72 on 09/01/26.
//

import Foundation
import AVFoundation
import MediaPlayer

final class AudioPlayerManager: NSObject {

    static let shared = AudioPlayerManager()

    private override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommandCenter()
    }

    private var player: AVPlayer?
    private var timeControlObserver: NSKeyValueObservation?

    var isRepeatEnabled: Bool = false
    private(set) var currentPodcast: Podcast?

    var onTrackFinished: (() -> Void)?
    var onStateChange: ((AVPlayer.TimeControlStatus) -> Void)?
    var onTrackStarted: ((Podcast) -> Void)?

    var isPlaying: Bool {
        return player?.timeControlStatus == .playing
    }

    // MARK: - Background Audio Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleInterruption),
                                                   name: AVAudioSession.interruptionNotification,
                                                   object: nil)
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }

    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        if type == .began {
            pause()
        } else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    resume()
                }
            }
        }
    }

    func play(podcast: Podcast) {
        stop()
        self.currentPodcast = podcast
        guard let url = URL(string: podcast.audioUrl) else { return }

        let item = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: item)

        player = AVPlayer(playerItem: item)
        player?.automaticallyWaitsToMinimizeStalling = true

        timeControlObserver = player?.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            DispatchQueue.main.async {
                self?.onStateChange?(player.timeControlStatus)
            }
        }

        player?.play()
        onTrackStarted?(podcast)
    }

    @objc private func playerDidFinishPlaying() {
        DispatchQueue.main.async {
            self.onTrackFinished?()
        }
    }

    func pause() {
        player?.pause()
        onStateChange?(.paused)
    }

    func resume() {
        player?.play()
        onStateChange?(.playing)
    }

    func stop() {
        player?.pause()
        player = nil
        timeControlObserver?.invalidate()
        timeControlObserver = nil
    }

    func seek(to seconds: Double) {
        let targetTime = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: targetTime)
    }
    
    var currentTime: Double {
        guard let currentTime = player?.currentTime() else { return 0 }
        return CMTimeGetSeconds(currentTime)
    }

    var duration: Double {
        guard let duration = player?.currentItem?.duration else { return 0 }
        let seconds = CMTimeGetSeconds(duration)
        return seconds.isFinite ? seconds : 0
    }
}

// MARK: - MediaPlayer Extension
extension AudioPlayerManager {

    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { _ in
            NotificationCenter.default.post(name: NSNotification.Name("RemoteNext"), object: nil)
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { _ in
            NotificationCenter.default.post(name: NSNotification.Name("RemotePrev"), object: nil)
            return .success
        }
    }

    func updateNowPlayingInfo(podcast: Podcast) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = podcast.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = podcast.author
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        if let url = URL(string: podcast.imageUrl) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    DispatchQueue.main.async {
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    }
                }
            }.resume()
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
