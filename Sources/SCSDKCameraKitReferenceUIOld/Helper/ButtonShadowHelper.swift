//  Copyright Snap Inc. All rights reserved.
//  SCSDKCameraKitReferenceUI

import UIKit

/// Helper to apply shadows to buttons.
public extension UIButton {
    /// Applies a shadow designed for camera action buttons.
    func applyCameraActionButtonShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.45
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 1)
    }
}
