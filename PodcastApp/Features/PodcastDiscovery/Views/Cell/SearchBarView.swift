//
//  SearchBarView.swift
//  PodcastApp
//
//  Created by MACM72 on 29/12/25.
//

import UIKit

@IBDesignable
class SearchBarView: UIView {

    @IBOutlet var containerView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

        private func commonInit() {
            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: "SearchBarView", bundle: bundle)

            // This line connects the XIB to this Swift file
            guard let xibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }

            xibView.frame = self.bounds
            xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(xibView)

        }
}
