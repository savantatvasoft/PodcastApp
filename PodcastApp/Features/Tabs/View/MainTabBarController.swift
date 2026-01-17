//
//  MainTabBarController.swift
//  PodcastApp
//
//  Created by MACM72 on 01/01/26.
//

import UIKit
import AVFoundation

class MainTabBarController: UITabBarController {

    private var miniPlayer: MiniPlayerView?
    private var currentIndex = 0
    private var podcasts: [Podcast] = []
    private let audioManager = AudioPlayerManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMiniPlayerUI()
        bindPlayerState()
    }

    private func setupMiniPlayerUI() {
        let nib = UINib(nibName: "MiniPlayerView", bundle: nil)
        guard let player = nib.instantiate(withOwner: nil).first as? MiniPlayerView else { return }

        view.addSubview(player)
        miniPlayer = player

        player.previousSong.transform = CGAffineTransform(scaleX: -1, y: 1)

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

    private func setupMiniPlayerActions() {
        miniPlayer?.didTapPlay = { [weak self] in
            guard let self = self else { return }
            self.audioManager.isPlaying ? self.audioManager.pause() : self.audioManager.resume()
        }

        miniPlayer?.didTapNext = { [weak self] in
            guard let self = self, !self.podcasts.isEmpty else { return }
            self.currentIndex = (self.currentIndex + 1) % self.podcasts.count
            self.syncPlayerState()
        }

        miniPlayer?.didTapPrevious = { [weak self] in
            guard let self = self, !self.podcasts.isEmpty else { return }
            if self.currentIndex > 0 {
                self.currentIndex -= 1
                self.syncPlayerState()
            }
        }

        miniPlayer?.didTapBackground = { [weak self] in
            self?.performSegue(withIdentifier: "showFullPlayer", sender: self)
        }
    }

    private func syncPlayerState() {
        guard let miniPlayer = miniPlayer, currentIndex < podcasts.count else { return }
        let podcast = podcasts[currentIndex]

        let canGoBack = currentIndex > 0
        miniPlayer.previousSong.alpha = canGoBack ? 1.0 : 0.3

        miniPlayer.configure(with: podcast)
        audioManager.stop()
        audioManager.play(podcast: podcast)
    }

    func updateMiniPlayer(with podcast: Podcast, from list: [Podcast]) {
        guard let miniPlayer = miniPlayer else { return }
        self.podcasts = list

        if let index = self.podcasts.firstIndex(where: { $0.id == podcast.id }) {
            currentIndex = index
        }

        miniPlayer.previousSong.alpha = (currentIndex > 0) ? 1.0 : 0.3
        miniPlayer.configure(with: podcast)
        miniPlayer.isHidden = false
        audioManager.play(podcast: podcast)
    }

    private func bindPlayerState() {
        audioManager.onStateChange = { [weak self] state in
            guard let self, let miniPlayer = self.miniPlayer else { return }
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFullPlayer" {
            if let destinationVC = segue.destination as? MusicPlayerVC {

                destinationVC.currentPodcast = podcasts[currentIndex]
                destinationVC.podcastList = podcasts
                destinationVC.currentIndex = currentIndex
            }
        }
    }
}
