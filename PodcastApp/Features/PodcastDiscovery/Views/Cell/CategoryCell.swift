//
//  CategoryCell.swift
//  PodcastApp
//
//  Created by MACM72 on 30/12/25.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CategoryCell"

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var bottomBorder: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = .clear
    }
    
    func configure(text: String, isSelected: Bool) {
        title.text = text
        bottomBorder.isHidden = !isSelected
        title.textColor = isSelected ? .systemRed : .systemGray
     
        title.font = UIFont(name: "Avenir-Heavy", size: isSelected ? 15 : 16)
       
        // This ensures the cell adjusts its width immediately if the font width changed
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
}
