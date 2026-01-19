//
//  MiniPlayerView.swift
//  PodcastApp
//
//  Created by MACM72 on 01/01/26.
//

import UIKit

class MiniPlayerView: UIView {

    // MARK: - Outlets
    @IBOutlet weak var previousSong: UIImageView!
    @IBOutlet weak var playView: UIImageView!
    @IBOutlet weak var nextSongView: UIImageView!
    @IBOutlet weak var songDescription: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!

    // MARK: - UI Components
    private let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .systemPurple
        return indicator
    }()

    // MARK: - Callbacks
    var didTapPlay: (() -> Void)?
    var didTapNext: (() -> Void)?
    var didTapPrevious: (() -> Void)?
    var didTapBackground: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupGestures()
        setupLoader()
    }

    private func setupUI() {
        previousSong.transform = CGAffineTransform(scaleX: -1, y: 1)
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        addSideBorder(side: .top, color: .systemGray4, width: 0.5)
    }

    private func setupLoader() {
        addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: playView.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: playView.centerYAnchor)
        ])
    }

    private func setupGestures() {
        [playView, nextSongView, previousSong, self].forEach { $0?.isUserInteractionEnabled = true }
        playView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playTapped)))
        nextSongView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextTapped)))
        previousSong.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previousTapped)))
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:))))
    }

    func configure(with podcast: Podcast, isPlaying: Bool, isLoading: Bool) {
        title.text = podcast.title
        songDescription.text = podcast.author
        imageView.loadImage(from: podcast.imageUrl)

        if isLoading {
            loader.startAnimating()
            playView.isHidden = true
        } else {
            loader.stopAnimating()
            playView.isHidden = false
            playView.image = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill")
        }
    }

    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let isButtonTouch = playView.frame.contains(location) ||
                           nextSongView.frame.contains(location) ||
                           previousSong.frame.contains(location)
        if !isButtonTouch { didTapBackground?() }
    }

    @objc private func playTapped() { didTapPlay?() }
    @objc private func nextTapped() { didTapNext?() }
    @objc private func previousTapped() { didTapPrevious?() }
}
