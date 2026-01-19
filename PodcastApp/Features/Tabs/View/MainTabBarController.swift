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
    let vm = PodcastDiscoveryVM()
    private let audioManager = AudioPlayerManager.shared
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMiniPlayerUI()
        bindPlayerState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindPlayerState()
        syncMiniPlayerUI()
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
            self?.vm.togglePlayPause()
            self?.syncMiniPlayerUI()
        }
        miniPlayer?.didTapNext = { [weak self] in
            self?.vm.playNext()
        }
        miniPlayer?.didTapPrevious = { [weak self] in
            self?.vm.playPrevious()
        }
        miniPlayer?.didTapBackground = { [weak self] in
            self?.openFullPlayer()
        }
    }

    func updateMiniPlayer(with podcast: Podcast, from list: [Podcast]) {
        vm.playPodcast(podcast, from: list)
        syncMiniPlayerUI()
    }

    private func syncMiniPlayerUI() {
        guard let podcast = vm.getCurrentPodcast() else { return }
        let index = vm.getPlayingIndex(in: vm.currentList) ?? 0

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let player = self.miniPlayer else { return }

            player.isHidden = false
            player.configure(with: podcast)

            let isPlaying = self.audioManager.isPlaying
            let imageName = isPlaying ? "pause.fill" : "play.fill"
            player.playView.image = UIImage(systemName: imageName)

            player.previousSong.alpha = (index > 0) ? 1.0 : 0.3
            self.view.bringSubviewToFront(player)
        }
    }

    private func bindPlayerState() {
        audioManager.onStateChange = { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self, let miniPlayer = self.miniPlayer else { return }
                let isPlaying = self.audioManager.isPlaying
                let imageName = isPlaying ? "pause.fill" : "play.fill"
                miniPlayer.playView.image = UIImage(systemName: imageName)
            }
        }

        audioManager.onTrackStarted = { [weak self] _ in
            self?.syncMiniPlayerUI()
        }

        audioManager.onTrackFinished = { [weak self] in
            guard let self = self else { return }

            if self.audioManager.isRepeatEnabled {
                self.audioManager.seek(to: 0)
                self.audioManager.resume()
                self.syncMiniPlayerUI()
            } else {
                self.vm.playNext()
            }
        }

    }

    private func openFullPlayer() {
        let storyboard = UIStoryboard(name: "PodcastDiscovery", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MusicPlayerVC") as? MusicPlayerVC {
            vc.vm = self.vm
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
}
