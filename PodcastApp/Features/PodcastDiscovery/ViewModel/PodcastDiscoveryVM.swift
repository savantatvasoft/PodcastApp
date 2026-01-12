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
    var totalSections: Int = 3


    private var currentPlayingIndex: Int?

    var filteredTrendingPodcasts: [Podcast] {
        let selectedType = categories[selectedCategoryIndex]
        return (selectedType == .all) ? MockData.allPodcasts : MockData.allPodcasts.filter { $0.category == selectedType }
    }

    var filteredFavouritePodcasts: [Podcast] {
        let selectedType = categories[selectedCategoryIndex]
        return (selectedType == .all) ? MockData.favoritePodcasts : MockData.favoritePodcasts.filter { $0.category == selectedType }
    }

    func selectCategory(at index: Int) {
        self.selectedCategoryIndex = index
    }
}
