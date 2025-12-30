//
//  TrendingCell.swift
//  PodcastApp
//
//  Created by MACM72 on 30/12/25.
//

import UIKit

class TrendingCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    static let reuseIdentifier = "TrendingCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = .clear
    }
    
    func configure(text: String, isSelected: Bool) {
        
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
}
