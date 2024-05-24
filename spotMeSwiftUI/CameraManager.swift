//
//  CameraManager.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import AVFoundation

class CameraManager: ObservableObject {
    @Published var error: CameraError?
    @Published var cameraStatus: String?
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label :"cameraQueue")
    private let videoOutput = AVCaptureVideoDataOutput()
    private var status = Status.uncofigured
    
    enum Status {
        case uncofigured
        case configured
        case failed
        case unauthorized
    }
    static let shared = CameraManager()
    private init() {
        configure()
    }
    
    
    func configure() {
        checkPermissions()
        sessionQueue.async {
            self.configureCameraSession()
            self.session.startRunning()
            self.cameraStatus = "running"
        }
    }
    func stopCamera() {
        sessionQueue.async {
            if (self.session.isRunning) {
                self.session.stopRunning()
                self.cameraStatus = "stopped"
            }
        }
    }
    
    private func set(error: CameraError?) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if !authorized {
                    self.status = .unauthorized
                    self.set(error: .deniedAuthorization)
                }
                self.sessionQueue.resume()
            }
        case .restricted:
            status = .unauthorized
            set(error: .restrictedAuthorization)
        case .denied:
            status = .unauthorized
            set(error: .deniedAuthorization)
        case .authorized:
            break
        @unknown default:
            status = .unauthorized
            set(error: .unknownAuthorization)
        }
    }
    
    
    
    private func configureCameraSession() {
        guard status == .uncofigured else {
            return
        }
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                             for: .video,
                                             position: .front)
        guard let camera = device else {
            set(error: .cameraUnavailable)
            status = .failed
            return
        }
        do {
            // 1
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            // 2
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            } else {
                // 3
                set(error: .cannotAddInput)
                status = .failed
                return
            }
        } catch {
            // 4
            set(error: .createCaptureInput(error))
            status = .failed
            return
        }
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            // 2
            videoOutput.videoSettings =
            [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            // 3
            let videoConnection = videoOutput.connection(with: .video)
            // Fix this based on the device orientation
            videoConnection?.videoRotationAngle  = 90.0
        } else {
            // 4
            set(error: .cannotAddOutput)
            status = .failed
            return
        }
        status = .configured
    }
    
    // This is exposed for video recorder to use the same settings for writing video
    func getVideoOutputSettings() -> [String: Any]? {
        return videoOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
    }
    
    func set(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
             queue: DispatchQueue) {
        sessionQueue.async {
            self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
        }
    }
    
}
