//
//  AppLayout.swift
//  PodcastApp
//
//  Created by MACM72 on 08/01/26.
//

import Foundation
import UIKit

struct AppLayout {

    static let trendingSectionHeight: CGFloat = 200.0

    private static var activeWindowScene: UIWindowScene? {
        return UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            ?? UIApplication.shared.connectedScenes.first as? UIWindowScene
    }

    static var windowWidth: CGFloat {
        return activeWindowScene?.screen.bounds.width ?? 0
    }

    static var windowHeight: CGFloat {
        return activeWindowScene?.screen.bounds.height ?? 0
    }

    static var isLandscape: Bool {
        return windowWidth > windowHeight
    }

    static var podcastWidthFactor: CGFloat {
        return isLandscape ? 0.2 : 0.4
    }


}
