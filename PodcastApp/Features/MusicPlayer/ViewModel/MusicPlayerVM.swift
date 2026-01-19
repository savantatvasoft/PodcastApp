//
//  MusicPlayerVM.swift
//  PodcastApp
//
//  Created by MACM72 on 19/01/26.
//

import Foundation

class MusicPlayerVM {
    private let audioManager = AudioPlayerManager.shared
    var podcastList: [Podcast] = []
    
    init(list: [Podcast]) {
        self.podcastList = list
    }
    
    func getPlayingIndex() -> Int? {
        guard let current = audioManager.currentPodcast else { return nil }
        return podcastList.firstIndex(where: { $0.id == current.id })
    }
    
    func playNext() {
        guard let index = getPlayingIndex(), index < podcastList.count - 1 else { return }
        audioManager.play(podcast: podcastList[index + 1])
    }
    
    func playPrevious() {
        guard let index = getPlayingIndex(), index > 0 else { return }
        audioManager.play(podcast: podcastList[index - 1])
    }
    
    func formatTime(seconds: Double) -> String {
        if seconds.isNaN || seconds.isInfinite { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
