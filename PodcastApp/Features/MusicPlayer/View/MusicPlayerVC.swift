//
//  MusicPlayerVC.swift
//  PodcastApp
//
//  Created by MACM72 on 16/01/26.
//

import UIKit
import AVFoundation

class MusicPlayerVC: UIViewController {

    var vm: PodcastDiscoveryVM?
    private var isRepeatEnabled: Bool = false
    private let audioManager = AudioPlayerManager.shared
    private var timer: Timer?
    private var isUserSeeking: Bool = false
    private var isFavorite: Bool = false

    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var banner: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var favourite: UIImageView!
    @IBOutlet weak var share: UIImageView!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var playView: UIImageView!
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var forwardView: UIImageView!
    @IBOutlet weak var repeatView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSlider()
        setupGestures()
        startPlaybackTimer()
        setupManagerCallbacks()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    private func setupUI() {
        guard let podcast = vm?.getCurrentPodcast() else { return }
        isRepeatEnabled = audioManager.isRepeatEnabled
        label.text = podcast.title
        author.text = podcast.author
        banner.loadImage(from: podcast.imageUrl)
        banner.layer.cornerRadius = 7
        banner.clipsToBounds = true

        updatePlayPauseUI()
        updateNavigationButtons()
    }

    private func setupManagerCallbacks() {
        audioManager.onStateChange = { [weak self] _ in
            self?.updatePlayPauseUI()
        }

        audioManager.onTrackStarted = { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.playbackSlider.value = 0
                self.currentTimeLabel.text = "0:00"
                self.setupUI()
            }
        }
    }

    private func updatePlayPauseUI() {
        let isPlaying = audioManager.isPlaying
        let imageName = isPlaying ? "pause.circle.fill" : "play.circle.fill"
        playView.image = UIImage(systemName: imageName)
    }

    @objc private func handlePlayPause() {
        vm?.togglePlayPause()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    @objc private func handleNext() {
        vm?.playNext()
        UISelectionFeedbackGenerator().selectionChanged()
    }

    @objc private func handlePrevious() {
        vm?.playPrevious()
        UISelectionFeedbackGenerator().selectionChanged()
    }

    private func updateNavigationButtons() {
        guard let vm = vm else { return }
        let index = vm.getPlayingIndex(in: vm.currentList) ?? 0

        let hasPrevious = index > 0
        backView.isUserInteractionEnabled = hasPrevious
        backView.alpha = hasPrevious ? 1.0 : 0.3

        let hasNext = index < vm.currentList.count - 1
        forwardView.isUserInteractionEnabled = hasNext
        forwardView.alpha = hasNext ? 1.0 : 0.3
    }

    private func setupSlider() {
        playbackSlider.minimumValue = 0
        playbackSlider.isContinuous = true

        let thumbSize: CGFloat = 24
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: thumbSize, height: thumbSize))
        let thumbImage = renderer.image { context in
            context.cgContext.setShadow(offset: CGSize(width: 0, height: 2), blur: 4, color: UIColor.black.withAlphaComponent(0.3).cgColor)
            UIColor.white.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 2, y: 2, width: thumbSize - 4, height: thumbSize - 4))
        }

        playbackSlider.setThumbImage(thumbImage, for: .normal)
        playbackSlider.addTarget(self, action: #selector(sliderTouchBegan(_:)), for: .touchDown)
        playbackSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        playbackSlider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
    }

    private func setupGestures() {
        [leftImageView, share, favourite, playView, backView, forwardView, repeatView].forEach { $0?.isUserInteractionEnabled = true }
        leftImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBackTap)))
        share.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShare)))
        favourite.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFavourite)))
        playView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePlayPause)))
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePrevious)))
        forwardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleNext)))
        repeatView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleRepeat)))
    }
    private func updateRepeatUI() {
        let isEnabled = audioManager.isRepeatEnabled
        repeatView.tintColor = isEnabled ? .systemPurple : .label
        repeatView.image = UIImage(systemName: isEnabled ? "repeat.1" : "repeat")
    }

    @objc private func handleRepeat() {
        audioManager.isRepeatEnabled.toggle()
        updateRepeatUI()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func startPlaybackTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateSliderProgress()
        }
    }

    private func updateSliderProgress() {
        if isUserSeeking { return }
        let currentTime = audioManager.currentTime
        let duration = audioManager.duration

        guard duration > 0, !duration.isNaN else { return }

        playbackSlider.maximumValue = Float(duration)
        playbackSlider.setValue(Float(currentTime), animated: false)
        currentTimeLabel.text = formatTime(seconds: currentTime)
        durationLabel.text = formatTime(seconds: duration)
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
        audioManager.seek(to: Double(sender.value))
        isUserSeeking = false
    }

    @objc private func handleBackTap() {
        dismiss(animated: true)
    }

    @objc private func handleShare() {
        guard let podcast = vm?.getCurrentPodcast() else { return }
        let ac = UIActivityViewController(activityItems: ["Check out: \(podcast.title)"], applicationActivities: nil)
        present(ac, animated: true)
    }

    @objc private func handleFavourite() {
        isFavorite.toggle()
        favourite.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
        favourite.tintColor = isFavorite ? .systemRed : .label
    }
}
