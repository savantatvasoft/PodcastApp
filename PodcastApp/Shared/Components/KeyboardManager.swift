//
//  KeyboardManager.swift
//  PodcastApp
//
//  Created by MACM72 on 08/01/26.
//

import Foundation
import UIKit

class KeyboardManager {

    private weak var scrollView: UIScrollView?
    private weak var viewController: UIViewController?
    private let extraPadding: CGFloat = 20

    init(collectionView: UICollectionView, viewController: UIViewController) {
        self.scrollView = collectionView
        self.viewController = viewController
    }

    func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setupTapToDismiss()
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupTapToDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        viewController?.view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        viewController?.view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let scrollView = scrollView,
              let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardHeight = keyboardFrame.cgRectValue.height
        let bottomInset = keyboardHeight + extraPadding
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)

        UIView.animate(withDuration: 0.3) {
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.scrollView?.contentInset = .zero
            self.scrollView?.scrollIndicatorInsets = .zero
        }
    }
}
