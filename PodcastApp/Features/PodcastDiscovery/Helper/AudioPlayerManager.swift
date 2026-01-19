//
//  AudioPlayerManager.swift
//  PodcastApp
//
//  Created by MACM72 on 09/01/26.
//

import Foundation
import AVFoundation

final class AudioPlayerManager {
    static let shared = AudioPlayerManager()
    private init() {}

    private var player: AVPlayer?
    private var timeControlObserver: NSKeyValueObservation?
    var isRepeatEnabled: Bool = false

    var onTrackFinished: (() -> Void)?
    var onStateChange: ((AVPlayer.TimeControlStatus) -> Void)?
    var onTrackStarted: ((Podcast) -> Void)?

    var isPlaying: Bool {
        return player?.timeControlStatus == .playing
    }

    var currentTime: Double {
        return player?.currentTime().seconds ?? 0
    }

    var duration: Double {
        return player?.currentItem?.duration.seconds ?? 0
    }

    func play(podcast: Podcast) {
        stop()
        guard let url = URL(string: podcast.audioUrl) else { return }
        let item = AVPlayerItem(url: url)

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: item)

        player = AVPlayer(playerItem: item)

        timeControlObserver = player?.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            DispatchQueue.main.async {
                self?.onStateChange?(player.timeControlStatus)
            }
        }

        player?.play()
        onTrackStarted?(podcast)
        onStateChange?(.playing)
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
        NotificationCenter.default.removeObserver(self)
        player?.pause()
        player = nil
        timeControlObserver?.invalidate()
        timeControlObserver = nil
    }

    func seek(to seconds: Double) {
        let targetTime = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: targetTime)
    }
}
