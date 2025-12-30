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
    
    private var selectedCategoryIndex = 0
    private let categories = ["All", "Stories", "Motivation", "Education", "Health", "Tech"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    private func setupCollectionView() {
        collectionView.setCollectionViewLayout(PodcastLayoutFactory.createDiscoveryLayout(), animated: false)
    }
    
}

// MARK: - UICollectionView DataSource
extension PodcastDiscoveryVC: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? categories.count : 20
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return provideCell(for: indexPath)
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
        let isSelected = (indexPath.item == selectedCategoryIndex)
        cell.configure(text: categories[indexPath.item], isSelected: isSelected)
        return cell
    }
    
    private func configureTrendingCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingCell.reuseIdentifier, for: indexPath) as! TrendingCell
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
        let previousIndex = selectedCategoryIndex
        selectedCategoryIndex = indexPath.item
        
        let oldIndexPath = IndexPath(item: previousIndex, section: 0)
        let newIndexPath = IndexPath(item: selectedCategoryIndex, section: 0)
        
        collectionView.reloadItems(at: [oldIndexPath, newIndexPath])
        collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
        
        print("Category selected: \(categories[selectedCategoryIndex])")
    }
    
    private func handleTrendingSelection(at indexPath: IndexPath) {
        print("Trending podcast selected at index: \(indexPath.item)")
    }
}
