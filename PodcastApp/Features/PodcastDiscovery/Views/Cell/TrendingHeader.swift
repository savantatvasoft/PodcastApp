//
//  TrendingHeader.swift
//  PodcastApp
//
//  Created by MACM72 on 30/12/25.
//

import UIKit

protocol TrendingHeaderDelegate:AnyObject {
    func didTapTrendingHeaderLeft()
}

class TrendingHeader: UICollectionReusableView {
    
    //MARK: Properties
    static let reuseIdentifier = "TrendingHeader"
    weak var delegate: TrendingHeaderDelegate?
    
    //MARK: Outlets
    @IBOutlet weak var leftImageView: UIButton!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func onPressLeft(_ sender: Any) {
        delegate?.didTapTrendingHeaderLeft() 
    }
    
}
