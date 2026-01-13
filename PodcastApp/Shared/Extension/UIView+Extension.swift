//
//  UIView+Extension.swift
//  PodcastApp
//
//  Created by MACM72 on 08/01/26.
//

import UIKit

extension UIView {

    enum BorderSide: String {
        case top, bottom, left, right
    }

    func findFirstResponder() -> UIView? {
        if isFirstResponder { return self }
        for subview in subviews {
            if let firstResponder = subview.findFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }

    func addSideBorder(side: BorderSide, color: UIColor, width: CGFloat) {

        let borderTag = 9000 + side.hashValue
        viewWithTag(borderTag)?.removeFromSuperview()

        let borderView = UIView()
        borderView.tag = borderTag
        borderView.backgroundColor = color
        borderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderView)

        switch side {
            case .top:
                NSLayoutConstraint.activate([
                    borderView.topAnchor.constraint(equalTo: topAnchor),
                    borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    borderView.heightAnchor.constraint(equalToConstant: width)
                ])

            case .bottom:
                NSLayoutConstraint.activate([
                    borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    borderView.heightAnchor.constraint(equalToConstant: width)
                ])

            case .left:
                NSLayoutConstraint.activate([
                    borderView.topAnchor.constraint(equalTo: topAnchor),
                    borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    borderView.widthAnchor.constraint(equalToConstant: width)
                ])

            case .right:
                NSLayoutConstraint.activate([
                    borderView.topAnchor.constraint(equalTo: topAnchor),
                    borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    borderView.widthAnchor.constraint(equalToConstant: width)
                ])
        }
    }
}
