//
//  MusicPlayerVC.swift
//  PodcastApp
//
//  Created by MACM72 on 16/01/26.
//

import UIKit
import AVFoundation

class MusicPlayerVC: UIViewController {

    var currentPodcast: Podcast?
    var podcastList: [Podcast] = []
    var currentIndex: Int = 0
    private var isFavorite: Bool = false

    private let audioManager = AudioPlayerManager.shared
    private var timer: Timer?
    private var isUserSeeking: Bool = false

    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var banner: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var favourite: UIImageView!
    @IBOutlet weak var share: UIImageView!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSlider()
        setupGestures()
        startPlaybackTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    private func setupUI() {
        guard let podcast = currentPodcast else { return }
        label.text = podcast.title
        author.text = podcast.author
        banner.loadImage(from: podcast.imageUrl)

        banner.layer.cornerRadius = 15
        banner.clipsToBounds = true

        favourite.image = UIImage(systemName: "heart")
        favourite.tintColor = .label

        currentTimeLabel.text = "0:00"
        durationLabel.text = "--:--"
    }

    private func setupSlider() {
        var currentView: UIView? = playbackSlider
        while currentView != nil {
            currentView?.isUserInteractionEnabled = true
            currentView = currentView?.superview
        }
        playbackSlider.superview?.bringSubviewToFront(playbackSlider)
        playbackSlider.isUserInteractionEnabled = true
        playbackSlider.isEnabled = true
        playbackSlider.minimumValue = 0
        playbackSlider.value = 0
        playbackSlider.isContinuous = true

        let thumbSize: CGFloat = 24
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: thumbSize, height: thumbSize))
        let thumbImage = renderer.image { context in
            context.cgContext.setShadow(offset: CGSize(width: 0, height: 2), blur: 4, color: UIColor.black.withAlphaComponent(0.3).cgColor)
            UIColor.white.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 2, y: 2, width: thumbSize - 4, height: thumbSize - 4))
        }

        playbackSlider.setThumbImage(thumbImage, for: .normal)
        playbackSlider.setThumbImage(thumbImage, for: .highlighted)

        playbackSlider.addTarget(self, action: #selector(sliderTouchBegan(_:)), for: .touchDown)
        playbackSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        playbackSlider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
        playbackSlider.addTarget(self, action: #selector(sliderTouchCancelled(_:)), for: .touchCancel)
    }

    private func setupGestures() {
        [leftImageView, share, favourite].forEach { $0?.isUserInteractionEnabled = true }

        leftImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBackTap)))
        share.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShare)))
        favourite.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFavourite)))
    }

    private func startPlaybackTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateSliderProgress()
        }
    }

    private func updateSliderProgress() {
        if playbackSlider.isTracking {
            return
        }

        let currentTime = audioManager.currentTime
        let duration = audioManager.duration

        guard duration > 0, !duration.isNaN else {
            playbackSlider.maximumValue = 1
            playbackSlider.value = 0
            durationLabel.text = "--:--"
            currentTimeLabel.text = "0:00"
            return
        }

        playbackSlider.maximumValue = Float(duration)
        playbackSlider.setValue(Float(currentTime), animated: false)

        currentTimeLabel.text = formatTime(seconds: currentTime)
        durationLabel.text = formatTime(seconds: duration)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playbackSlider.superview?.bringSubviewToFront(playbackSlider)
    }

    private func formatTime(seconds: Double) -> String {
        if seconds.isNaN || seconds.isInfinite { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    @objc private func sliderTouchBegan(_ sender: UISlider) {
        isUserSeeking = true
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        currentTimeLabel.text = formatTime(seconds: Double(sender.value))
    }

    @objc private func sliderTouchUp(_ sender: UISlider) {
        let targetTime = Double(sender.value)
        audioManager.seek(to: targetTime)
        isUserSeeking = false
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    @objc private func sliderTouchCancelled(_ sender: UISlider) {
        isUserSeeking = false
    }

    @objc private func handleBackTap() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func handleShare() {
        guard let podcast = currentPodcast else { return }
        let items = ["Check out this episode: \(podcast.title)"]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }

    @objc private func handleFavourite() {
        isFavorite.toggle()

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        UIView.transition(with: favourite, duration: 0.2, options: .transitionCrossDissolve) {
            self.favourite.image = UIImage(systemName: self.isFavorite ? "heart.fill" : "heart")
            self.favourite.tintColor = self.isFavorite ? .systemRed : .label
        }
    }
}
