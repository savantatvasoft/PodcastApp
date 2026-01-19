//
//  PodcastListVC.swift
//  PodcastApp
//
//  Created by MACM72 on 31/12/25.
//

import UIKit

class PodcastListVC: UIViewController {

    @IBOutlet weak var collctionView: UICollectionView!
    private var selectedIndex: Int?
    var podcasts: [Podcast] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        observeAudioChanges()
    }

    private func setupCollectionView() {
        let headerNib = UINib(nibName: "Header", bundle: nil)
        collctionView.register(headerNib,
                              forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                              withReuseIdentifier: Header.reuseIdentifier)

        // Set delegates if not done in Storyboard
        collctionView.dataSource = self
        collctionView.delegate = self

        if let layout = collctionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.headerReferenceSize = CGSize(width: collctionView.bounds.width, height: 50)
            layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        }
    }

    private func observeAudioChanges() {
        // Refresh when track changes (e.g., user clicks 'Next' in MiniPlayer)
        AudioPlayerManager.shared.onTrackStarted = { [weak self] _ in
            DispatchQueue.main.async {
                self?.syncSelectedIndex()
                self?.collctionView.reloadData()
            }
        }
    }

    private func syncSelectedIndex() {
        // Find the index of the currently playing podcast in our local list
        guard let currentID = AudioPlayerManager.shared.currentPodcast?.id else { return }
        selectedIndex = podcasts.firstIndex(where: { $0.id == currentID })
    }
}

// MARK: - Header Delegate
extension PodcastListVC: HeaderDelegate {
    func didTapBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - CollectionView DataSource
extension PodcastListVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PodcastListCell", for: indexPath) as! PodcastListCell
        let podcast = podcasts[indexPath.item]

        // Check if this specific podcast is the one playing globally
        let currentPlayingID = AudioPlayerManager.shared.currentPodcast?.id
        let isSelected = (podcast.id == currentPlayingID)

        cell.configure(with: podcast, isSelected: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: Header.reuseIdentifier,
            for: indexPath
        ) as! Header
        header.delegate = self
        header.configure(with: "Trending Podcasts", showBackIcon: true)
        return header
    }
}

// MARK: - CollectionView Delegate
extension PodcastListVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPodcast = podcasts[indexPath.item]

        // 1. Update the Global Discovery VM list so the player knows the sequence
        if let mainTabBar = self.tabBarController as? MainTabBarController {
            mainTabBar.discoveryVM.updateCurrentList(podcasts)
        }

        // 2. Play using the Global Manager
        AudioPlayerManager.shared.play(podcast: selectedPodcast)

        collectionView.reloadData()
    }
}

extension PodcastListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 60)
    }
}
