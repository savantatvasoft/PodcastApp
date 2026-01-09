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

    private let vm = PodcastDiscoveryVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    private func setupCollectionView() {
        let headerNib = UINib(nibName: "TrendingHeader", bundle: nil)
        collectionView.register(headerNib,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: "TrendingHeader")
        collectionView.setCollectionViewLayout(PodcastLayoutFactory.createDiscoveryLayout(), animated: false)
    }
    
}


extension PodcastDiscoveryVC: TrendingHeaderDelegate {

    func didTapTrendingHeaderLeft() {
        performSegue(withIdentifier: "showPodcastList", sender: nil)
    }
    
}

// MARK: - UICollectionView DataSource
extension PodcastDiscoveryVC: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? vm.categories.count : vm.filteredPodcasts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return provideCell(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrendingHeader.reuseIdentifier,
            for: indexPath
        ) as? TrendingHeader else {
            return UICollectionReusableView()
        }
        header.delegate = self
        header.title.text = "Trending Podcast"
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
        case 0:
            return configureCategoryCell(at: indexPath)
        case 1:
            return configureTrendingCell(at: indexPath)
        default:
            return UICollectionViewCell()
        }
    }
    
    private func configureCategoryCell(at indexPath: IndexPath) -> CategoryCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as! CategoryCell
        let category = vm.categories[indexPath.item]
        let isSelected = (indexPath.item == vm.selectedCategoryIndex)
        cell.configure(text: category.rawValue, isSelected: isSelected)
        return cell
    }
    
    private func configureTrendingCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingCell.reuseIdentifier, for: indexPath) as! TrendingCell
        let podcast = vm.filteredPodcasts[indexPath.item]
        cell.configure(with: podcast)
        return cell
    }
}


// MARK: - CollectionView Action Handler
extension PodcastDiscoveryVC {
    
    func handleSelection(at indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            handleCategorySelection(at: indexPath)
        case 1:
            handleTrendingSelection(at: indexPath)
        default:
            break
        }
    }
    
    private func handleCategorySelection(at indexPath: IndexPath) {
        let previousIndex = vm.selectedCategoryIndex
        vm.selectedCategoryIndex = indexPath.item

        let oldIndexPath = IndexPath(item: previousIndex, section: 0)
        let newIndexPath = IndexPath(item: vm.selectedCategoryIndex, section: 0)

        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: [oldIndexPath, newIndexPath])
            collectionView.reloadSections(IndexSet(integer: 1))
        }, completion: { _ in
            self.collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
        })

        UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
    
    private func handleTrendingSelection(at indexPath: IndexPath) {
        let selectedPodcast = MockData.allPodcasts[indexPath.item]
//        vm.didSelectPodcast(selectedPodcast, index: indexPath.item)
        if let mainTabBar = self.tabBarController as? MainTabBarController {
            mainTabBar.updateMiniPlayer(with: selectedPodcast)
        }
    }
}
