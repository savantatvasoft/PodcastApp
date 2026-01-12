//
//  PodcastListCell.swift
//  PodcastApp
//
//  Created by MACM72 on 01/01/26.
//

import UIKit
import Kingfisher

class PodcastListCell: UICollectionViewCell {

    @IBOutlet weak var conatinerView: UIView!
    @IBOutlet weak var imgUrl: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var authorName: UILabel!

    @IBOutlet weak var rightImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        conatinerView.backgroundColor = .systemGray5

        imgUrl.backgroundColor = .systemGray5
        imgUrl.clipsToBounds = true
        imgUrl.contentMode = .scaleAspectFill
        imgUrl.image = UIImage(named: "music.note")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imgUrl.layoutIfNeeded()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imgUrl.cancelImageLoad()
        imgUrl.image = UIImage(named: "music.note")
    }

    func configure(with podcast: Podcast) {
        title.text = podcast.title
        authorName.text = podcast.author
        imgUrl.loadImage(from: podcast.imageUrl)
    }
}
