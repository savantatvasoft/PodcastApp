//
//  MiniPlayerView.swift
//  PodcastApp
//
//  Created by MACM72 on 01/01/26.
//

import UIKit

class MiniPlayerView: UIView {
    
    var isPlaying = false

    @IBOutlet weak var playView: UIImageView!
    @IBOutlet weak var nextSongView: UIImageView!
    @IBOutlet weak var songDescription: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!

    var didTapPlay: (() -> Void)?
    var didTapNext: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSideBorder(side: .top, color: .systemGray4, width: 0.5)
        setupGestures()
    }
    
    private func setupGestures() {
        playView.isUserInteractionEnabled = true
        nextSongView.isUserInteractionEnabled = true

        let playTap = UITapGestureRecognizer(target: self, action: #selector(playTapped))
        playView.addGestureRecognizer(playTap)
        
        let nextTap = UITapGestureRecognizer(target: self, action: #selector(nextTapped))
        nextSongView.addGestureRecognizer(nextTap)
    }
    
    @objc private func playTapped() {
        didTapPlay?()
    }
    
    @objc private func nextTapped() {
        didTapNext?()
    }
    
    func configure(with podcast: Podcast) {
        title.text = podcast.title
        songDescription.text = podcast.author
        imageView.loadImage(from: podcast.imageUrl)
    }
}
