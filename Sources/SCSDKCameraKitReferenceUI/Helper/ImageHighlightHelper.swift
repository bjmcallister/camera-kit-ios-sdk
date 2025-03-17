//  Copyright Snap Inc. All rights reserved.
//  SCSDKCameraKitReferenceUI

import UIKit

/// Helper to produce highlighted versions of some camera action button images.
extension UIImage {
    /// Produces a version of the image that is subtracted from a circle with the given radius and color.
    /// - Parameters:
    ///   - radius: The radius of the circle to subtract the image from.
    ///   - color: The color of the circle to subtract the image from.
    /// - Returns: The image subtracted from the circle with the provided radius and color.
    public func circleHighlightedImage(radius: CGFloat, color: UIColor = .white) -> UIImage? {
        guard let circleImage = UIImage.circleImage(radius: radius, color: color) else { return nil }
        return subtractedImage(baseImage: circleImage)
    }

    /// Produces an image of a circle with the given radius and color.
    /// - Parameters:
    ///   - radius: The radius of the circle.
    ///   - color: The color of the circle.
    /// - Returns: The image of the circle with the provided radius and color.
    private static func circleImage(radius: CGFloat, color: UIColor = .white) -> UIImage? {
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: 0,
            endAngle: 2.0 * .pi,
            clockwise: true
        )

        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath

        let pathBounds = circlePath.cgPath.boundingBoxOfPath
        let shapeFrame = CGRect(
            x: pathBounds.origin.x,
            y: pathBounds.origin.y,
            width: pathBounds.size.width,
            height: pathBounds.size.height
        )

        circleLayer.fillColor = color.cgColor
        circleLayer.bounds = shapeFrame
        circleLayer.frame = circleLayer.bounds

        let renderer = UIGraphicsImageRenderer(size: circleLayer.frame.size)
        return renderer.image(actions: { circleLayer.render(in: $0.cgContext) })
    }

    /// Subtracts the image from the center of the provided base image.
    /// - Parameter baseImage: The image from which the image is subtracted from.
    /// - Returns: The subtracted version of the image.
    private func subtractedImage(baseImage: UIImage) -> UIImage? {
        UIGraphicsImageRenderer(size: baseImage.size).image(actions: { context in
            baseImage.draw(at: .zero)
            draw(
                at: CGPoint(x: (baseImage.size.width - size.width) / 2, y: (baseImage.size.height - size.height) / 2),
                blendMode: .destinationOut,
                alpha: 1.0
            )
        })
    }
}
