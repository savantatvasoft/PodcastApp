//
//  UIImageView+Extension.swift
//  PodcastApp
//
//  Created by MACM72 on 12/01/26.
//

import UIKit

extension UIImageView {
    func loadImage(from urlString: String, placeholder: String = "music.note") {
        ImageLoader.shared.load(into: self, from: urlString, placeholder: placeholder)
    }

    func cancelImageLoad() {
        ImageLoader.shared.cancel(for: self)
    }
}
