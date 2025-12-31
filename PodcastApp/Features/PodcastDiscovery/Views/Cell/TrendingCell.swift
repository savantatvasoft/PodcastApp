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
    }
    
    private func setupUI() {
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = .clear
    }
    
    func configure(with podcast: Podcast) {
            title.text = podcast.title
            language.text = podcast.category.rawValue
            if let url = URL(string: podcast.imageUrl) {
                // Basic async loading (Consider using Kingfisher for better performance)
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                        }
                    }
                }.resume()
            }
            
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        }
}
