//
//  MainTabBarController.swift
//  PodcastApp
//
//  Created by MACM72 on 01/01/26.
//

import UIKit

class MainTabBarController: UITabBarController {

    private var miniPlayer: MiniPlayerView?
    private let audioManager = AudioPlayerManager.shared
    let discoveryVM = PodcastDiscoveryVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMiniPlayerUI()

        // Initialize the Notification Bar commands
        audioManager.setupRemoteCommandCenter()

        // Listen for the "Next/Prev" signals sent from the Notification Bar
        NotificationCenter.default.addObserver(self, selector: #selector(autoPlayNext), name: NSNotification.Name("RemoteNext"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(autoPlayPrevious), name: NSNotification.Name("RemotePrev"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindPlayerState()
        syncMiniPlayerUI()
    }

    private func bindPlayerState() {
        audioManager.onTrackStarted = { [weak self] podcast in
            self?.syncMiniPlayerUI()
            self?.audioManager.updateNowPlayingInfo(podcast: podcast)
        }

        audioManager.onStateChange = { [weak self] _ in
            self?.syncMiniPlayerUI()
            if let current = self?.audioManager.currentPodcast {
                        self?.audioManager.updateNowPlayingInfo(podcast: current)
            }
        }

        audioManager.onTrackFinished = { [weak self] in
            guard let self = self else { return }
            self.audioManager.isRepeatEnabled ? self.handleRepeat() : self.autoPlayNext()
        }
    }

    private func handleRepeat() {
        audioManager.seek(to: 0)
        audioManager.resume()
    }

    @objc func autoPlayNext() {
        let list = discoveryVM.currentList
        guard let current = audioManager.currentPodcast,
              let index = list.firstIndex(where: { $0.id == current.id }),
              index < list.count - 1 else { return }
        audioManager.play(podcast: list[index + 1])
    }

    @objc func autoPlayPrevious() {
        let list = discoveryVM.currentList
        guard let current = audioManager.currentPodcast,
              let index = list.firstIndex(where: { $0.id == current.id }),
              index > 0 else { return }
        audioManager.play(podcast: list[index - 1])
    }

    private func syncMiniPlayerUI() {
        guard let podcast = audioManager.currentPodcast else {
            miniPlayer?.isHidden = true
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let player = self.miniPlayer else { return }
            player.isHidden = false
            let list = self.discoveryVM.currentList
            if let index = list.firstIndex(where: { $0.id == podcast.id }) {
                player.previousSong.alpha = index > 0 ? 1.0 : 0.3
                player.nextSongView.alpha = index < list.count - 1 ? 1.0 : 0.3
            }

            player.configure(
                with: podcast,
                isPlaying: self.audioManager.isPlaying,
                isLoading: false
            )
        }
    }

    private func setupMiniPlayerUI() {
        let nib = UINib(nibName: "MiniPlayerView", bundle: nil)
        guard let player = nib.instantiate(withOwner: nil).first as? MiniPlayerView else { return }

        view.addSubview(player)
        miniPlayer = player
        player.isHidden = true
        player.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            player.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            player.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            player.heightAnchor.constraint(equalToConstant: 70),
            player.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        ])

        player.didTapPlay = { [weak self] in
            guard let self = self else { return }
            self.audioManager.isPlaying ? self.audioManager.pause() : self.audioManager.resume()
        }

        player.didTapNext = { [weak self] in
            self?.autoPlayNext()
        }

        player.didTapPrevious = { [weak self] in
            self?.autoPlayPrevious()
        }

        player.didTapBackground = { [weak self] in
            self?.openFullPlayer()
        }
    }

    func openFullPlayer() {
        let storyboard = UIStoryboard(name: "PodcastDiscovery", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MusicPlayerVC") as? MusicPlayerVC {
            vc.vm = MusicPlayerVM(list: discoveryVM.currentList)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
}
