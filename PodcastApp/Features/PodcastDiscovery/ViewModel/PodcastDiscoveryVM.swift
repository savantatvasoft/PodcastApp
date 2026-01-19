//
//  PodcastDiscoveryVM.swift
//  PodcastApp
//
//  Created by MACM72 on 09/01/26.
//

import Foundation
import AVFoundation

class PodcastDiscoveryVM {
    var selectedCategoryIndex: Int = 0
    var categories = CategoryType.allCases
    var totalSections: Int = 3

    private(set) var currentPlayingPodcastID: String?
    private(set) var currentList: [Podcast] = []
    private let audioManager = AudioPlayerManager.shared

    var filteredTrendingPodcasts: [Podcast] {
        let selectedType = categories[selectedCategoryIndex]
        return (selectedType == .all) ? MockData.allPodcasts : MockData.allPodcasts.filter { $0.category == selectedType }
    }

    var filteredFavouritePodcasts: [Podcast] {
        let selectedType = categories[selectedCategoryIndex]
        return (selectedType == .all) ? MockData.favoritePodcasts : MockData.favoritePodcasts.filter { $0.category == selectedType }
    }

    func playPodcast(_ podcast: Podcast, from list: [Podcast]) {
        self.currentList = list
        self.currentPlayingPodcastID = podcast.id
        audioManager.play(podcast: podcast)
    }

    func togglePlayPause() {
        audioManager.isPlaying ? audioManager.pause() : audioManager.resume()
    }

    func playNext() {
        guard let currentIndex = getPlayingIndex(in: currentList),
              currentIndex < currentList.count - 1 else { return }
        playPodcast(currentList[currentIndex + 1], from: currentList)
    }

    func playPrevious() {
        guard let currentIndex = getPlayingIndex(in: currentList),
              currentIndex > 0 else { return }
        playPodcast(currentList[currentIndex - 1], from: currentList)
    }

    func selectCategory(at index: Int) {
        self.selectedCategoryIndex = index
    }

    func isPodcastPlaying(id: String) -> Bool {
        return currentPlayingPodcastID == id
    }

    func getPlayingIndex(in list: [Podcast]) -> Int? {
        guard let id = currentPlayingPodcastID else { return nil }
        return list.firstIndex(where: { $0.id == id })
    }

    func getCurrentPodcast() -> Podcast? {
        return currentList.first(where: { $0.id == currentPlayingPodcastID })
    }

    var isPlaying: Bool {
        return audioManager.isPlaying
    }
}
