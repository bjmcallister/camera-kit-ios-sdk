//  Copyright Snap Inc. All rights reserved.
//  SCSDKCameraKitReferenceUI

import UIKit

public class RingLightColorSelectionViewCell: UICollectionViewCell {
    public static let reuseIdentifer = "ringLightColorSelectionViewCell"

    // MARK: Layers

    /// Inner circle with the color option the cell represents.
    private lazy var innerCircleLayer: CAShapeLayer = {
        let innerCirclePath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: 16,
            startAngle: 0,
            endAngle: 2.0 * .pi,
            clockwise: true
        )

        let layer = CAShapeLayer()
        layer.path = innerCirclePath.cgPath

        return layer
    }()

    /// Outer circle that is used as a "highlight" when this color option is selected.
    private lazy var outerCircleLayer: CAShapeLayer = {
        let outerCirclePath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: 20,
            startAngle: 0,
            endAngle: 2.0 * .pi,
            clockwise: true
        )

        let layer = CAShapeLayer()
        layer.path = outerCirclePath.cgPath
        layer.isHidden = true
        layer.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor

        return layer
    }()

    // MARK: Public

    /// Used to set the color option that the cell represents.
    /// - Parameter color: The color to set for the cell.
    public func setColor(_ color: UIColor) {
        innerCircleLayer.fillColor = color.cgColor
    }

    /// Used to highlight the color option that this cell represents when selected.
    public func highlight() {
        outerCircleLayer.isHidden = false
    }

    /// Remove the highlight from this cell.
    public func unhighlight() {
        outerCircleLayer.isHidden = true
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        [outerCircleLayer, innerCircleLayer].forEach(layer.addSublayer)
    }

    override public var intrinsicContentSize: CGSize {
        CGSize(width: 48, height: 48)
    }
}
