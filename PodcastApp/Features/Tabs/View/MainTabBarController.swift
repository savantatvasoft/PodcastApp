//
//  MainTabBarController.swift
//  PodcastApp
//
//  Created by MACM72 on 01/01/26.
//

import UIKit

class MainTabBarController: UITabBarController {

    var miniPlayer: MiniPlayerView?
    var isPlaying = false
    var currentIndex = 0
    var podcasts: [Podcast] = MockData.allPodcasts

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMiniPlayerUI()
    }

    private func setupMiniPlayerUI() {
        let nib = UINib(nibName: "MiniPlayerView", bundle: nil)
        
        // Change 'withOwner: self' to 'withOwner: nil'
        guard let player = nib.instantiate(withOwner: nil, options: nil).first as? MiniPlayerView else {
            return
        }
        
        self.view.addSubview(player)
        self.miniPlayer = player
        
        // Constraints...
        player.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            player.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            player.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            player.heightAnchor.constraint(equalToConstant: 70),
            player.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        ])
        
        player.isHidden = true
        setupPlayerCallbacks()
    }
    
    private func setupPlayerCallbacks() {
           
        miniPlayer?.didTapPlay = { [weak self] in
           guard let self = self else { return }
           self.isPlaying.toggle()
           let iconName = self.isPlaying ? "pause.fill" : "play.fill"
           self.miniPlayer?.playView.image = UIImage(systemName: iconName)
        }

        miniPlayer?.didTapNext = { [weak self] in
            guard let self = self else { return }
            self.currentIndex = (self.currentIndex + 1) % self.podcasts.count
            let nextPodcast = self.podcasts[self.currentIndex]
            self.updateMiniPlayer(with: nextPodcast)
        }
    }

    func updateMiniPlayer(with podcast: Podcast) {
        guard let player = miniPlayer else { return }
        if let index = podcasts.firstIndex(where: { $0.id == podcast.id }) {
            self.currentIndex = index
        }
        player.configure(with: podcast)
        self.isPlaying = true
        player.playView.image = UIImage(systemName: "pause.fill")
        
        if player.isHidden {
            player.isHidden = false
        }
    }
}
