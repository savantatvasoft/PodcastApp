//
//  Header.swift
//  PodcastApp
//
//  Created by MACM72 on 13/01/26.
//

import UIKit

protocol HeaderDelegate: AnyObject {
    func didTapBack()
}

class Header: UICollectionReusableView {

    static let reuseIdentifier = "Header"

    @IBOutlet weak var backIcon: UIImageView!
    @IBOutlet weak var title: UILabel!

    weak var delegate: HeaderDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        backIcon.image = UIImage(systemName: "chevron.backward")
        backIcon.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backTapped))
        backIcon.addGestureRecognizer(tapGesture)
    }

    @objc private func backTapped() {
        delegate?.didTapBack()
    }

    func configure(with text: String, showBackIcon: Bool = false) {
        title.text = text
        backIcon.isHidden = !showBackIcon
    }
}
