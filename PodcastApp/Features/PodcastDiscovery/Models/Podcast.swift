//
//  Podcast.swift
//  PodcastApp
//
//  Created by MACM72 on 31/12/25.
//

import Foundation

enum CategoryType: String, CaseIterable, Codable {
    case all = "All"
    case stories = "Stories"
    case motivation = "Motivation"
    case education = "Education"
    case health = "Health"
    case tech = "Tech"
    case music = "Music"
}

struct PodcastCategory: Identifiable, Codable {
    let id: String
    let type: CategoryType
}

struct Podcast: Identifiable, Codable {
    let id: String
    let title: String
    let author: String
    let category: CategoryType
    let imageUrl: String
    let audioUrl: String
    let rating: Double
    let views: String
}


struct MockData {
    // 1. Generate Category Objects from Enum
    static let categories: [PodcastCategory] = CategoryType.allCases.map {
        PodcastCategory(id: UUID().uuidString, type: $0)
    }
    
    // 2. Generate 20 Dummy Podcasts
    static let allPodcasts: [Podcast] = [
        Podcast(id: "1", title: "The Tech Revolution", author: "Alex Rivera", category: .tech, imageUrl: "https://picsum.photos/seed/1/400/400", audioUrl: "", rating: 4.9, views: "1.2M"),
        Podcast(id: "2", title: "Mindset Matters", author: "Sarah Chen", category: .motivation, imageUrl: "https://picsum.photos/seed/2/400/400", audioUrl: "", rating: 4.8, views: "850K"),
        Podcast(id: "3", title: "History Unfolded", author: "James Miller", category: .stories, imageUrl: "https://picsum.photos/seed/3/400/400", audioUrl: "", rating: 4.7, views: "500K"),
        Podcast(id: "4", title: "The Daily Story", author: "Emily Rose", category: .stories, imageUrl: "https://picsum.photos/seed/4/400/400", audioUrl: "", rating: 4.9, views: "2.1M"),
        Podcast(id: "5", title: "Deep Meditation", author: "Zen Master", category: .health, imageUrl: "https://picsum.photos/seed/5/400/400", audioUrl: "", rating: 4.6, views: "120K"),
        Podcast(id: "6", title: "Future AI", author: "Cyber Sarah", category: .tech, imageUrl: "https://picsum.photos/seed/6/400/400", audioUrl: "", rating: 4.8, views: "900K"),
        Podcast(id: "7", title: "Startup Stories", author: "Silicon Sam", category: .education, imageUrl: "https://picsum.photos/seed/7/400/400", audioUrl: "", rating: 4.5, views: "300K"),
        Podcast(id: "8", title: "Yoga Vibes", author: "Adriene", category: .health, imageUrl: "https://picsum.photos/seed/8/400/400", audioUrl: "", rating: 4.9, views: "1.5M"),
        Podcast(id: "9", title: "Indie Beats", author: "DJ Echo", category: .music, imageUrl: "https://picsum.photos/seed/9/400/400", audioUrl: "", rating: 4.7, views: "450K"),
        Podcast(id: "10", title: "Business Daily", author: "John Galt", category: .education, imageUrl: "https://picsum.photos/seed/10/400/400", audioUrl: "", rating: 4.4, views: "200K"),
        Podcast(id: "11", title: "Space Odyssey", author: "Astro Ben", category: .education, imageUrl: "https://picsum.photos/seed/11/400/400", audioUrl: "", rating: 4.8, views: "700K"),
        Podcast(id: "12", title: "The Horror Hour", author: "Night Owl", category: .stories, imageUrl: "https://picsum.photos/seed/12/400/400", audioUrl: "", rating: 4.9, views: "3.2M"),
        Podcast(id: "13", title: "Coding Life", author: "Dev Dan", category: .tech, imageUrl: "https://picsum.photos/seed/13/400/400", audioUrl: "", rating: 4.6, views: "150K"),
        Podcast(id: "14", title: "Healthy Eating", author: "Chef Nutri", category: .health, imageUrl: "https://picsum.photos/seed/14/400/400", audioUrl: "", rating: 4.5, views: "400K"),
        Podcast(id: "15", title: "Marketing 101", author: "Ad Guru", category: .education, imageUrl: "https://picsum.photos/seed/15/400/400", audioUrl: "", rating: 4.3, views: "90K"),
        Podcast(id: "16", title: "Jazz Lounge", author: "Smooth Sax", category: .music, imageUrl: "https://picsum.photos/seed/16/400/400", audioUrl: "", rating: 4.7, views: "250K"),
        Podcast(id: "17", title: "Crime Scene", author: "Agent Mulder", category: .stories, imageUrl: "https://picsum.photos/seed/17/400/400", audioUrl: "", rating: 4.9, views: "2.8M"),
        Podcast(id: "18", title: "Physics Fun", author: "Prof. Proton", category: .education, imageUrl: "https://picsum.photos/seed/18/400/400", audioUrl: "", rating: 4.8, views: "550K"),
        Podcast(id: "19", title: "Gadget Talk", author: "Tech Tom", category: .tech, imageUrl: "https://picsum.photos/seed/19/400/400", audioUrl: "", rating: 4.7, views: "600K"),
        Podcast(id: "20", title: "Zen Living", author: "Peaceful Pat", category: .health, imageUrl: "https://picsum.photos/seed/20/400/400", audioUrl: "", rating: 4.6, views: "180K")
    ]
}

func getFilteredPodcasts(for categoryType: CategoryType) -> [Podcast] {
    if categoryType == .all {
        return MockData.allPodcasts
    } else {
        return MockData.allPodcasts.filter { $0.category == categoryType }
    }
}

// Get the high-rated ones for "Top Podcast" section
var topPodcasts: [Podcast] {
    return MockData.allPodcasts.filter { $0.rating >= 4.8 }
}
