//
//  MusicPlayerVC.swift
//  PodcastApp
//
//  Created by MACM72 on 16/01/26.
//

import UIKit
import AVFoundation

class MusicPlayerVC: UIViewController {

    // MARK: - Properties
    var vm: MusicPlayerVM!
    private let audioManager = AudioPlayerManager.shared
    private var timer: Timer?
    private var isUserSeeking: Bool = false
    private var isFavorite: Bool = false

    // MARK: - Outlets
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSlider()
        setupGestures()
        setupManagerCallbacks()
        startPlaybackTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    // MARK: - Setup
    private func setupUI() {
        // We now get current data from the AudioManager (Source of Truth)
        guard let podcast = audioManager.currentPodcast else { return }

        label.text = podcast.title
        author.text = podcast.author
        banner.loadImage(from: podcast.imageUrl)
        banner.layer.cornerRadius = 15
        banner.clipsToBounds = true

        updatePlayPauseUI()
        updateRepeatUI()
        updateNavigationButtons()
    }

    private func setupManagerCallbacks() {
        audioManager.onStateChange = { [weak self] _ in
            DispatchQueue.main.async {
                self?.updatePlayPauseUI()
            }
        }

        audioManager.onTrackStarted = { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                // Reset slider immediately when a new track starts
                self.playbackSlider.value = 0
                self.currentTimeLabel.text = "0:00"
                self.setupUI()
            }
        }
    }

    // MARK: - UI Updates
    private func updatePlayPauseUI() {
        let imageName = audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill"
        playView.image = UIImage(systemName: imageName)
    }

    private func updateRepeatUI() {
        let isEnabled = audioManager.isRepeatEnabled
        repeatView.tintColor = isEnabled ? .systemPurple : .label
        repeatView.image = UIImage(systemName: isEnabled ? "repeat.1" : "repeat")
    }

    private func updateNavigationButtons() {
        // Get navigation logic from VM
        let index = vm.getPlayingIndex() ?? 0

        let hasPrevious = index > 0
        backView.isUserInteractionEnabled = hasPrevious
        backView.alpha = hasPrevious ? 1.0 : 0.3

        let hasNext = index < vm.podcastList.count - 1
        forwardView.isUserInteractionEnabled = hasNext
        forwardView.alpha = hasNext ? 1.0 : 0.3
    }

    // MARK: - Actions
    @objc private func handlePlayPause() {
        if audioManager.isPlaying {
            audioManager.pause()
        } else {
            audioManager.resume()
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    @objc private func handleNext() {
        vm.playNext()
        UISelectionFeedbackGenerator().selectionChanged()
    }

    @objc private func handlePrevious() {
        vm.playPrevious()
        UISelectionFeedbackGenerator().selectionChanged()
    }

    @objc private func handleRepeat() {
        audioManager.isRepeatEnabled.toggle()
        updateRepeatUI()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - Slider & Timer
    private func setupSlider() {
        playbackSlider.minimumValue = 0
        playbackSlider.isContinuous = true

        // Custom Thumb setup
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

    private func startPlaybackTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateSliderProgress()
        }
    }

    private func updateSliderProgress() {
        guard !isUserSeeking else { return }

        let current = audioManager.currentTime
        let duration = audioManager.duration

        guard duration > 0, !duration.isNaN else { return }

        playbackSlider.maximumValue = Float(duration)
        playbackSlider.setValue(Float(current), animated: false)

        // Use VM for formatting strings
        currentTimeLabel.text = vm.formatTime(seconds: current)
        durationLabel.text = vm.formatTime(seconds: duration)
    }

    @objc private func sliderTouchBegan(_ sender: UISlider) {
        isUserSeeking = true
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        currentTimeLabel.text = vm.formatTime(seconds: Double(sender.value))
    }

    @objc private func sliderTouchUp(_ sender: UISlider) {
        audioManager.seek(to: Double(sender.value))
        isUserSeeking = false
    }

    // MARK: - Other Gestures
    private func setupGestures() {
        [leftImageView, share, favourite, playView, backView, forwardView, repeatView].forEach {
            $0?.isUserInteractionEnabled = true
        }

        leftImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBackTap)))
        share.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShare)))
        favourite.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFavourite)))
        playView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePlayPause)))
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePrevious)))
        forwardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleNext)))
        repeatView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleRepeat)))
    }

    @objc private func handleBackTap() {
        dismiss(animated: true)
    }

    @objc private func handleShare() {
        guard let podcast = audioManager.currentPodcast else { return }
        let items = ["Check out this podcast: \(podcast.title)"]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }

    @objc private func handleFavourite() {
        isFavorite.toggle()
        favourite.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
        favourite.tintColor = isFavorite ? .systemRed : .label
    }
}
