//  Copyright Snap Inc. All rights reserved.
//  CameraKit

import UIKit

/// Popup message notification view for different lens events
public class MessageNotificationView: UIView {
    /// Default label in the message notification view
    public let label: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = MessageNotificationElements.label.id
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    public init() {
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
        backgroundColor = UIColor.black.withAlphaComponent(0.65)
        layer.cornerRadius = 4.0
        addSubview(label)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0),
        ])
    }
}
