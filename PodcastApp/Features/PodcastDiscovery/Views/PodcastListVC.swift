//
//  PodcastListVC.swift
//  PodcastApp
//
//  Created by MACM72 on 31/12/25.
//

import UIKit

class PodcastListVC: UIViewController {

    @IBOutlet weak var collctionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    private func setupCollectionView() {
        if let layout = collctionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
        }
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
        cell.configure(with: podcast)
        return cell
    }
}

// MARK: - Flow Layout (Fixes Width to 0-0 Leading/Trailing)
extension PodcastListVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.bounds.width
        return CGSize(width: screenWidth, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
}
