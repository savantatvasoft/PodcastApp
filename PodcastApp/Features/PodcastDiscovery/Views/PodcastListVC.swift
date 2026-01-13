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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    private func setupCollectionView() {
        let headerNib = UINib(nibName: "Header", bundle: nil)
        collctionView.register(headerNib,
                              forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                              withReuseIdentifier: Header.reuseIdentifier)

        if let layout = collctionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.headerReferenceSize = CGSize(width: collctionView.bounds.width, height: 50)
            layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        }
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
        return MockData.allPodcasts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PodcastListCell", for: indexPath) as! PodcastListCell
        let podcast = MockData.allPodcasts[indexPath.item]
        let isSelected = (indexPath.item == selectedIndex)
        cell.configure(with: podcast,isSelected: isSelected)
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
        let selectedPodcast = MockData.allPodcasts[indexPath.item]
        selectedIndex = indexPath.item
        if let mainTabBar = self.tabBarController as? MainTabBarController {
            mainTabBar.updateMiniPlayer(with: selectedPodcast)
        }
        collectionView.reloadData()
    }
}

extension PodcastListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 60)
    }
}
