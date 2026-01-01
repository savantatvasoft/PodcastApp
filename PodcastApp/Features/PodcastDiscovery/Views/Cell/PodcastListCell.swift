//
//  PodcastListCell.swift
//  PodcastApp
//
//  Created by MACM72 on 01/01/26.
//

import UIKit

class PodcastListCell: UICollectionViewCell {
    
    @IBOutlet weak var conatinerView: UIView!
    @IBOutlet weak var imgUrl: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var authorName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = .clear
    }
    
    func configure(with podcast: Podcast) {
        title.text = podcast.title
        authorName.text = podcast.author
          
            if let url = URL(string: podcast.imageUrl) {
                // Basic async loading (Consider using Kingfisher for better performance)
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.imgUrl.image = image
                        }
                    }
                }.resume()
            }
            
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
    }
    
}
