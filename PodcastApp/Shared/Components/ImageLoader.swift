//
//  ImageLoader.swift
//  PodcastApp
//
//  Created by MACM72 on 12/01/26.
//

import UIKit
import Kingfisher

final class ImageLoader {

    static let shared = ImageLoader()
    private init() {}

    func load(
        into imageView: UIImageView,
        from urlString: String,
        placeholder: String = "music.note",
        size: CGSize? = nil
    ) {
        guard let url = URL(string: urlString) else {
            imageView.image = UIImage(named: placeholder)
            return
        }

        let targetSize = size ?? imageView.bounds.size
        let processor = DownsamplingImageProcessor(size: targetSize)
        let scale = imageView.traitCollection.displayScale

        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: placeholder),
            options: [
                .processor(processor),
                .scaleFactor(scale),
                .transition(.fade(0.2)),
                .cacheOriginalImage,
                .backgroundDecode
            ]
        )
    }

    func cancel(for imageView: UIImageView) {
        imageView.kf.cancelDownloadTask()
    }
}
