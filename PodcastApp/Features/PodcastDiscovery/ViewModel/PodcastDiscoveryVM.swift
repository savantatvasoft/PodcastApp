//
//  PodcastDiscoveryVM.swift
//  PodcastApp
//
//  Created by MACM72 on 09/01/26.
//

import Foundation

class PodcastDiscoveryVM {

    var selectedCategoryIndex: Int = 0
    var categories = CategoryType.allCases

    // Keep track of what is playing globally within this screen
    private var currentPlayingIndex: Int?

    var filteredPodcasts: [Podcast] {
        let selectedType = categories[selectedCategoryIndex]
        return (selectedType == .all) ? MockData.allPodcasts : MockData.allPodcasts.filter { $0.category == selectedType }
    }

    func selectCategory(at index: Int) {
        self.selectedCategoryIndex = index
    }

//    func didSelectPodcast(_ podcast: Podcast, index: Int) {
//        self.currentPlayingIndex = index
//        AudioPlayerManager.shared.play(podcast: podcast)
//    }

//    func togglePlayback() {
//        if AudioPlayerManager.shared.isPlaying {
//            AudioPlayerManager.shared.pause()
//        } else {
//            AudioPlayerManager.shared.resume()
//        }
//    }
//
//    func playNext() {
//        guard let currentIndex = currentPlayingIndex else { return }
//        let nextIndex = currentIndex + 1
//        guard nextIndex < filteredPodcasts.count else {
//            print("End of list")
//            return
//        }
//        let nextPodcast = filteredPodcasts[nextIndex]
//        didSelectPodcast(nextPodcast, index: nextIndex)
//    }
}
