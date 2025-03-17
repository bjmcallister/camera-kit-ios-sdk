//  Copyright Snap Inc. All rights reserved.
//  SCSDKCameraKitReferenceUI

import UIKit

/// Helper to produce a dismissal hint for various camera action controls.
public extension UILabel {
    /// Produces a dismissal hint label for the control.
    /// - Returns: The dismissal hint label.
    static func controlDismissalHint() -> UILabel {
        let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.65)
        label.font = UIFont.sc_mediumFont(size: 12)
        label.text = CameraKitLocalizedString(key: "camera_kit_tap_to_dismiss", comment: "")
        label.textAlignment = .center
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.45
        label.layer.shadowRadius = 2
        label.layer.shadowOffset = CGSize(width: 0, height: 1)

        return label
    }
}
