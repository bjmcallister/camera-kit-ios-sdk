//  Copyright Snap Inc. All rights reserved.
//  CameraKit

import AVFoundation
import SCSDKCameraKit
import UIKit

/// Sample video recorder implementation.
public class Recorder {

    /// The URL to write the video to.
    private let outputURL: URL

    /// The AVWriterOutput for CameraKit.
    public let output: AVWriterOutput

    fileprivate let writer: AVAssetWriter
    fileprivate let videoInput: AVAssetWriterInput
    fileprivate let pixelBufferInput: AVAssetWriterInputPixelBufferAdaptor

    private let audioInput: AVAssetWriterInput = {
        let compressionAudioSettings: [String: Any] =
            [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVEncoderBitRateKey: 128000,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
            ]

        let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: compressionAudioSettings)
        audioInput.expectsMediaDataInRealTime = true
        return audioInput
    }()

    /// Designated initializer.
    /// - Parameters:
    ///   - url: output URL of video file.
    ///   - orientation: current orientation of device.
    ///   - size: video output size.
    ///   - captureConnection: (Optional) The AVCaptureConnection from your camera output.
    ///                        Pass this in to log its default mirroring behavior and adjust your transform.
    /// - Throws: Throws an error if the asset writer cannot be created.
    public init(url: URL,
                orientation: AVCaptureVideoOrientation,
                size: CGSize,
                captureConnection: AVCaptureConnection? = nil) throws {
        outputURL = url
        writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
        videoInput = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoHeightKey: size.height,
                AVVideoWidthKey: size.width,
                AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
            ]
        )
        videoInput.expectsMediaDataInRealTime = true

        // Check the capture connection for default mirroring.
        if let connection = captureConnection {
            print("Is video mirroring enabled by default: \(connection.isVideoMirrored)")
            // Use the connection's mirroring value to set the transform.
            videoInput.transform = Recorder.affineTransform(orientation: orientation, mirrored: connection.isVideoMirrored, size: size)
        } else {
            // Default to no manual mirroring.
            videoInput.transform = Recorder.affineTransform(orientation: orientation, mirrored: false, size: size)
        }

        pixelBufferInput = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            ]
        )

        writer.add(videoInput)
        writer.add(audioInput)

        output = AVWriterOutput(avAssetWriter: writer, pixelBufferInput: pixelBufferInput, audioInput: audioInput)
    }

    public func startRecording() {
        writer.startWriting()
        output.startRecording()
    }

    public func finishRecording(completion: ((URL?, Error?) -> Void)?) {
        output.stopRecording()
        videoInput.markAsFinished()
        audioInput.markAsFinished()
        writer.finishWriting { [weak self] in
            completion?(self?.outputURL, nil)
        }
    }

    /// Adjusts the video transform based on the device orientation, mirror setting, and video size.
    static private func affineTransform(orientation: AVCaptureVideoOrientation, mirrored: Bool, size: CGSize) -> CGAffineTransform {
        var transform: CGAffineTransform = .identity
        switch orientation {
        case .portraitUpsideDown:
            transform = transform.rotated(by: .pi)
        case .landscapeRight:
            transform = transform.rotated(by: .pi / 2)
        case .landscapeLeft:
            transform = transform.rotated(by: -.pi / 2)
        default:
            break
        }

        if mirrored {
            // For portrait, translate by the video's width before applying the horizontal flip.
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }

        return transform
    }
}

private extension AVCaptureVideoOrientation {
    var isPortrait: Bool {
        return self == .portrait || self == .portraitUpsideDown
    }
}
