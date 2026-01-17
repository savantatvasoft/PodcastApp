//
//  AudioPlayerManager.swift
//  PodcastApp
//
//  Created by MACM72 on 09/01/26.
//

import Foundation
import AVFoundation

final class AudioPlayerManager {

    // MARK: - Singleton
    static let shared = AudioPlayerManager()
    private init() {}

    // MARK: - Player
    private var player: AVPlayer?
    private var timeControlObserver: NSKeyValueObservation?
    var currentTime: Double {
        return player?.currentTime().seconds ?? 0
    }

    var duration: Double {
        return player?.currentItem?.duration.seconds ?? 0
    }

    var onStateChange: ((AVPlayer.TimeControlStatus) -> Void)?
    var onTrackStarted: ((Podcast) -> Void)?

    // MARK: - Computed Properties
    var isPlaying: Bool {
        player?.timeControlStatus == .playing
    }

    private func configureSession(mode: AVAudioSession.Mode) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: mode)
            try session.setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }

    private func observePlayerState() {
        timeControlObserver = player?.observe(
            \.timeControlStatus,
            options: [.initial, .new]
        ) { [weak self] player, _ in
            DispatchQueue.main.async {
                self?.onStateChange?(player.timeControlStatus)
            }
        }
    }

    func play(
        podcast: Podcast,
        mode: AVAudioSession.Mode = .spokenAudio
    ) {
        stop()
        configureSession(mode: mode)

        guard let url = URL(string: podcast.audioUrl) else { return }
        let item = AVPlayerItem(url: url)

        if player == nil {
            player = AVPlayer(playerItem: item)
            observePlayerState()
        } else {
            player?.replaceCurrentItem(with: item)
        }

        player?.play()
        onTrackStarted?(podcast)
    }

    func pause() {
        player?.pause()
    }

    func resume() {
        player?.play()
    }

    func stop() {
        player?.pause()
        player = nil
        timeControlObserver?.invalidate()
        timeControlObserver = nil
        onStateChange?(.paused)
    }

    func seek(to seconds: Double) {
        let targetTime = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: targetTime)
    }
}
