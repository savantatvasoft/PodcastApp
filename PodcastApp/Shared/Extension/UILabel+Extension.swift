//
//  UILabel+Extension.swift
//  PodcastApp
//
//  Created by MACM72 on 12/01/26.
//

import UIKit

extension UILabel {

    @IBInspectable
    var capitalizeFirst: Bool {
        get { return false }
        set {
            guard let currentText = self.text, !currentText.isEmpty else { return }

            if newValue {
                let firstChar = currentText.prefix(1).uppercased()
                let remainingText = currentText.dropFirst()

                self.text = firstChar + remainingText
            }
        }
    }

}
