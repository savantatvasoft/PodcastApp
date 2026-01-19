//
//  PodcastDiscoveryVC.swift
//  PodcastApp
//
//  Created by MACM72 on 29/12/25.
//

import UIKit

class PodcastDiscoveryVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchbarView: SearchBarView!

    // Get the VM from the TabBar safely
    private var vm: PodcastDiscoveryVM? {
        return (tabBarController as? MainTabBarController)?.discoveryVM
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        observeAudioChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    private func observeAudioChanges() {
        // Refresh UI when a track starts (to show which one is playing)
        AudioPlayerManager.shared.onTrackStarted = { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    private func setupCollectionView() {
        let headerNib = UINib(nibName: "TrendingHeader", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TrendingHeader")

        // Delegate and DataSource usually set in Storyboard, but good to ensure here
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.setCollectionViewLayout(PodcastLayoutFactory.createDiscoveryLayout(), animated: false)
    }

    deinit {
        AudioPlayerManager.shared.onTrackStarted = nil
    }
}

// MARK: - TrendingHeaderDelegate
extension PodcastDiscoveryVC: TrendingHeaderDelegate {

    func didTapTrendingHeaderLeft(for title: String) {
        performSegue(withIdentifier: "showPodcastList", sender: title)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPodcastList",
           let destinationVC = segue.destination as? PodcastListVC,
           let headerTitle = sender as? String {

            destinationVC.hidesBottomBarWhenPushed = false
            // Passing filtered data based on header title
            destinationVC.podcasts = (headerTitle == "Trending Podcast") ? (vm?.filteredTrendingPodcasts ?? []) : (vm?.filteredFavouritePodcasts ?? [])
        }
    }
}

// MARK: - UICollectionView DataSource
extension PodcastDiscoveryVC: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return vm?.totalSections ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let vm = vm else { return 0 }
        switch section {
            case 0: return vm.categories.count
            case 1: return vm.filteredTrendingPodcasts.count
            case 2: return vm.filteredFavouritePodcasts.count
            default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return provideCell(for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TrendingHeader", for: indexPath) as? TrendingHeader else {
            return UICollectionReusableView()
        }
        header.delegate = self
        header.title.text = (indexPath.section == 1) ? "Trending Podcast" : (indexPath.section == 2 ? "Favourite Podcasts" : "")
        return header
    }
}

// MARK: - UICollectionView Delegate
extension PodcastDiscoveryVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        handleSelection(at: indexPath)
    }
}

// MARK: - CollectionView Item Provider
extension PodcastDiscoveryVC {

    func provideCell(for indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0: return configureCategoryCell(at: indexPath)
        case 1: return configureTrendingCell(at: indexPath)
        case 2: return configureFavouriteCell(at: indexPath)
        default: return UICollectionViewCell()
        }
    }

    private func configureCategoryCell(at indexPath: IndexPath) -> CategoryCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        if let vm = vm {
            let category = vm.categories[indexPath.item]
            cell.configure(text: category.rawValue, isSelected: indexPath.item == vm.selectedCategoryIndex)
        }
        return cell
    }

    private func configureTrendingCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingCell", for: indexPath) as! TrendingCell
        if let vm = vm {
            let podcast = vm.filteredTrendingPodcasts[indexPath.item]
            cell.configure(with: podcast)
        }
        return cell
    }

    private func configureFavouriteCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingCell", for: indexPath) as! TrendingCell
        if let vm = vm {
            let podcast = vm.filteredFavouritePodcasts[indexPath.item]
            cell.configure(with: podcast)
        }
        return cell
    }
}

// MARK: - CollectionView Action Handler
extension PodcastDiscoveryVC {

    func handleSelection(at indexPath: IndexPath) {
        switch indexPath.section {
        case 0: handleCategorySelection(at: indexPath)
        case 1, 2: handlePodcastSelection(at: indexPath)
        default: break
        }
    }

    private func handleCategorySelection(at indexPath: IndexPath) {
        vm?.selectCategory(at: indexPath.item)
        UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.collectionView.reloadData()
        }, completion: { _ in
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        })
    }

    private func handlePodcastSelection(at indexPath: IndexPath) {
        guard let vm = vm else { return }

        // Determine which list the user is playing from
        let list = (indexPath.section == 1) ? vm.filteredTrendingPodcasts : vm.filteredFavouritePodcasts
        let selectedPodcast = list[indexPath.item]

        // 1. Update the "Global Queue" in the discovery VM so the TabBar knows what's next
        vm.currentList = list

        // 2. Play using the Manager directly
        AudioPlayerManager.shared.play(podcast: selectedPodcast)

        collectionView.reloadData()
    }
}
