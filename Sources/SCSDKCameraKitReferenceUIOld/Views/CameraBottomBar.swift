//  Copyright Snap Inc. All rights reserved.
//  CameraKit

import UIKit

/// Bottom bar on Camera that contains Snap ghost button for actions
/// as well as close button to clear current lens
public class CameraBottomBar: UIView {
    private enum Constants {
        static let snapImage = "ck_snap_ghost"
        static let closeCircle = "ck_close_circle"
    }

    /// Snap ghost button for lens actions
    public let snapButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setImage(
            UIImage(named: Constants.snapImage, in: BundleHelper.resourcesBundle, compatibleWith: nil), for: .normal
        )
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    /// Close button to clear current lens
    public let closeButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = CameraBottomBarElements.closeButton.id
        button.isHidden = true
        button.setImage(
            UIImage(named: Constants.closeCircle, in: BundleHelper.resourcesBundle, compatibleWith: nil), for: .normal
        )
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubview(snapButton)
        addSubview(closeButton)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            snapButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30.0),
            snapButton.topAnchor.constraint(equalTo: topAnchor),
            closeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            closeButton.centerYAnchor.constraint(equalTo: snapButton.centerYAnchor),
        ])
    }
}
