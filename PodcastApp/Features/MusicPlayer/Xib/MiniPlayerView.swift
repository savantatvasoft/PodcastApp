//
//  MiniPlayerView.swift
//  PodcastApp
//
//  Created by MACM72 on 01/01/26.
//
import UIKit

class MiniPlayerView: UIView {

    var isPlaying = false

    @IBOutlet weak var previousSong: UIImageView!
    @IBOutlet weak var playView: UIImageView!
    @IBOutlet weak var nextSongView: UIImageView!
    @IBOutlet weak var songDescription: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!

    var didTapPlay: (() -> Void)?
    var didTapNext: (() -> Void)?
    var didTapPrevious: (() -> Void)?
    var didTapBackground: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        previousSong.transform = CGAffineTransform(scaleX: -1, y: 1)
        previousSong.alpha = 0.3

        addSideBorder(side: .top, color: .systemGray4, width: 0.5)
        setupGestures()
    }

    private func setupGestures() {
        // 1. Enable interaction for controls
        playView.isUserInteractionEnabled = true
        nextSongView.isUserInteractionEnabled = true
        previousSong.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true

        // 2. Control Gestures
        playView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playTapped)))
        nextSongView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextTapped)))
        previousSong.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previousTapped)))

        // 3. Background Gesture (The rest of the area)
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        self.addGestureRecognizer(backgroundTap)
    }

    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let isButtonTouch = playView.frame.contains(location) ||
                           nextSongView.frame.contains(location) ||
                           previousSong.frame.contains(location)

        if !isButtonTouch {
            print("Background area tapped")
            didTapBackground?()
        }
    }

    @objc private func playTapped() {
        print("playTapped")
        didTapPlay?()
    }

    @objc private func nextTapped() {
        print("nextTapped")
        didTapNext?()
    }

    @objc private func previousTapped() {
        print("previousTapped")
        didTapPrevious?()
    }

    func configure(with podcast: Podcast) {
        title.text = podcast.title
        songDescription.text = podcast.author
        imageView.loadImage(from: podcast.imageUrl)
    }
}
