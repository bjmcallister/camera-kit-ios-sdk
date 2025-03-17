import AVFoundation
import Foundation
import SCSDKCameraKit

class MirrorAVSessionInput: NSObject, Input {
    var destination: InputDestination?
    private(set) var frameSize: CGSize
    private(set) var frameOrientation: AVCaptureVideoOrientation
    var position: AVCaptureDevice.Position {
        didSet {
            guard position != oldValue else { return }
            videoSession.beginConfiguration()
            if let videoDeviceInput { videoSession.removeInput(videoDeviceInput) }
            if let device = captureDevice {
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if videoSession.canAddInput(input) { videoSession.addInput(input) }
                    update(input: input, isAsync: false)
                    videoSession.commitConfiguration()
                    destination?.inputChangedAttributes(self)
                } catch {
                    debugPrint("[\(String(describing: self))]: Failed to add \(position) input")
                }
            }
        }
    }

    private var captureDevice: AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: position)
    }

    var isRunning: Bool { videoSession.isRunning }
    var horizontalFieldOfView: CGFloat { fieldOfView }

    private var fieldOfView: CGFloat
    private var isVideoMirrored: Bool
    private var format: AVCaptureDevice.Format?
    private var prevCaptureInput: AVCaptureInput?
    private var videoOrientation: AVCaptureVideoOrientation

    private let context = CIContext()
    private let videoSession: AVCaptureSession
    private let videoOutput: AVCaptureVideoDataOutput

    private var videoDeviceInput: AVCaptureDeviceInput? {
        deviceInput(for: .video, session: videoSession)
    }

    private var videoConnection: AVCaptureConnection? {
        videoOutput.connection(with: .video)
    }

    private let videoQueue: DispatchQueue
    private let configurationQueue: DispatchQueue

    init(session: AVCaptureSession, fieldOfView: CGFloat = Constants.defaultFieldOfView) {
        self.fieldOfView = fieldOfView
        self.videoSession = session
        self.frameOrientation = .portrait
        self.configurationQueue = DispatchQueue(label: "com.snap.mirror.avsessioninput.configuration")
        self.videoOutput = AVCaptureVideoDataOutput()
        self.videoQueue = DispatchQueue(label: "com.snap.mirror.videoOutput")
        self.frameSize = UIScreen.main.bounds.size
        self.position = .front
        self.isVideoMirrored = true
        self.videoOrientation = .landscapeLeft
        super.init()

        videoSession.beginConfiguration()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        if videoSession.canAddOutput(videoOutput) { videoSession.addOutput(videoOutput) }
        videoConnection?.videoOrientation = videoOrientation
        videoSession.commitConfiguration()
    }

    func startRunning() {
        restoreFormat()
        videoSession.startRunning()
    }

    func stopRunning() {
        storeFormat()
        videoSession.stopRunning()
    }

    func setVideoOrientation(_ videoOrientation: AVCaptureVideoOrientation) {
        self.videoOrientation = videoOrientation
        destination?.inputChangedAttributes(self)
        configurationQueue.async { [weak self] in
            self?.videoConnection?.videoOrientation = videoOrientation
        }
    }
}

extension MirrorAVSessionInput: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        if output == videoOutput {
            if let input = connection.inputPorts.first?.input, input != prevCaptureInput {
                update(input: input)
                destination?.inputChangedAttributes(self)
            }
            destination?.input(self, receivedVideoSampleBuffer: sampleBuffer)
        }
    }
}

private extension MirrorAVSessionInput {
    func restoreFormat() {
        if let format, let device = videoDeviceInput?.device {
            do {
                try device.lockForConfiguration()
                device.activeFormat = format
                device.unlockForConfiguration()
                self.format = nil
            } catch {
                debugPrint("[\(String(describing: self))]: Failed to restore format")
            }
        }
    }

    func storeFormat() {
        format = videoDeviceInput?.device.activeFormat
    }

    func deviceInput(for mediaType: AVMediaType, session: AVCaptureSession) -> AVCaptureDeviceInput? {
        for input in session.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput, deviceInput.device.hasMediaType(mediaType) {
                return deviceInput
            }
        }
        return nil
    }

    func update(input: AVCaptureInput, isAsync: Bool = true) {
        if let input = input as? AVCaptureDeviceInput {
            fieldOfView = CGFloat(input.device.activeFormat.videoFieldOfView)
            position = input.device.position
            format = input.device.activeFormat
        }

        isVideoMirrored = position == .front

        if isAsync {
            configurationQueue.async { [weak self] in
                self?.updateConnection()
            }
        } else {
            updateConnection()
        }

        prevCaptureInput = input
    }

    func updateConnection() {
        if let isMirrored = videoConnection?.isVideoMirrored, isMirrored != isVideoMirrored {
            videoConnection?.isVideoMirrored = isVideoMirrored
        }

        if let orientation = videoConnection?.videoOrientation, orientation != videoOrientation {
            videoConnection?.videoOrientation = videoOrientation
        }
    }
}

extension MirrorAVSessionInput {
    enum Constants {
        static let defaultFieldOfView: CGFloat = 78.0
    }
}
