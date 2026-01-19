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
    let totalSections: Int = 3
    var currentList: [Podcast] = MockData.allPodcasts

    var filteredTrendingPodcasts: [Podcast] {
        let selectedType = categories[selectedCategoryIndex]
        if selectedType == .all {
            return MockData.allPodcasts
        }
        return MockData.allPodcasts.filter { $0.category == selectedType }
    }

    var filteredFavouritePodcasts: [Podcast] {
        let selectedType = categories[selectedCategoryIndex]
        if selectedType == .all {
            return MockData.favoritePodcasts
        }
        return MockData.favoritePodcasts.filter { $0.category == selectedType }
    }

    func selectCategory(at index: Int) {
        self.selectedCategoryIndex = index
    }

    /// Updates the current active playlist (called when a user taps a podcast in a specific section)
    func updateCurrentList(_ list: [Podcast]) {
        self.currentList = list
    }
}
