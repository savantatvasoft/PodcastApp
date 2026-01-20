//
//  TrendingCell.swift
//  PodcastApp
//
//  Created by MACM72 on 30/12/25.
//

import UIKit

class TrendingCell: UICollectionViewCell {

    static let reuseIdentifier = "TrendingCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var language: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.cancelImageLoad()
    }

    private func setupUI() {
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = .clear
    }

    func configure(with podcast: Podcast) {
            title.text = podcast.title
            language.text = podcast.category.rawValue
            imageView.loadImage(from: podcast.imageUrl)
    }
}
