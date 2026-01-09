//
//  MainTabBarController.swift
//  PodcastApp
//
//  Created by MACM72 on 01/01/26.
//

import UIKit
import AVFoundation

//AVPlayer → AudioPlayerManager → MainTabBarController → MiniPlayerView

class MainTabBarController: UITabBarController {

    private var miniPlayer: MiniPlayerView?
    private var currentIndex = 0
    private var podcasts: [Podcast] = MockData.allPodcasts

    private let audioManager = AudioPlayerManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMiniPlayerUI()
        bindPlayerState()
    }

    // MARK: - Mini Player UI

    private func setupMiniPlayerUI() {
        let nib = UINib(nibName: "MiniPlayerView", bundle: nil)
        guard let player = nib.instantiate(withOwner: nil).first as? MiniPlayerView else {
            return
        }

        view.addSubview(player)
        miniPlayer = player

        player.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            player.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            player.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            player.heightAnchor.constraint(equalToConstant: 70),
            player.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        ])

        player.isHidden = true
        setupMiniPlayerActions()
    }

    // MARK: - Actions

    private func setupMiniPlayerActions() {

        miniPlayer?.didTapPlay = { [weak self] in
            guard let self else { return }

            switch self.audioManager.isPlaying {
            case true:
                self.audioManager.pause()
            case false:
                self.audioManager.resume()
            }
        }

        miniPlayer?.didTapNext = { [weak self] in
            guard let self else { return }

            self.currentIndex = (self.currentIndex + 1) % self.podcasts.count
            let podcast = self.podcasts[self.currentIndex]
            self.audioManager.stop()
            self.audioManager.play(podcast: podcast)
            self.updateMiniPlayer(with: podcast)
        }
    }

    // MARK: - Player State Binding (🔥 IMPORTANT)

    private func bindPlayerState() {
        audioManager.onStateChange = { [weak self] state in
            guard let self, let miniPlayer else { return }

            DispatchQueue.main.async {
                switch state {
                case .playing:
                    miniPlayer.playView.image = UIImage(systemName: "pause.fill")

                case .paused:
                    miniPlayer.playView.image = UIImage(systemName: "play.fill")

                case .waitingToPlayAtSpecifiedRate:
                    miniPlayer.playView.image = UIImage(systemName: "hourglass")

                @unknown default:
                    break
                }
            }
        }
    }

    // MARK: - External Entry Point

    func updateMiniPlayer(with podcast: Podcast) {
        guard let miniPlayer else { return }

        if let index = podcasts.firstIndex(where: { $0.id == podcast.id }) {
            currentIndex = index
        }

        miniPlayer.configure(with: podcast)
        miniPlayer.isHidden = false
        audioManager.play(podcast: podcast)
    }
}
