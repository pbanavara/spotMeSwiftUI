//
//  FrameManager.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import AVFoundation
import UIKit

class FrameManager:NSObject, ObservableObject {
    static let shared = FrameManager()
    let poseUtil = OnnxPoseUtils()
    var ortSession: ORTSession?
    @Published var current: CVPixelBuffer?
    @Published var poseImage:UIImage?
    @Published var imageTimeStamp: ImageTimeStamp = ImageTimeStamp()
    private var _filename = ""
    private var _time:Double = 0.0
    private var _assetWriter: AVAssetWriter?
    private var _assetWriterInput: AVAssetWriterInput?
    private var _adapter: AVAssetWriterInputPixelBufferAdaptor?
    private var _captureState: CaptureState?
    struct ImageTimeStamp {
        var image: UIImage?
        var timestamp: Double?
    }
    
    let videoOutputQueue = DispatchQueue(label: "videoOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    private override init() {
        super.init()
        CameraManager.shared.set(self, queue: videoOutputQueue)
        DispatchQueue.global(qos: .userInitiated).async {
            self.ortSession = PoseModel.shared.ortSession
        }
    }
    
    func setActionState(state: Bool) {
        switch state {
        case true:
            self._captureState = .end
        case false:
            self._captureState = .start
            
        }
        
    }
    enum CaptureState {
        case idle, start, capturing, end
    }
    
    private func convertUIImageToPixelBuffer(input: UIImage) -> CVPixelBuffer {
        var pbInput:CVPixelBuffer? = nil
        guard let cgInput = input.cgImage else {
                return pbInput!
            }

            // Image size
            let width = cgInput.width
            let height = cgInput.height
            let region = CGRect(x: 0, y: 0, width: width, height: height)

            // Attributes needed to create the CVPixelBuffer
            let attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                              kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]

            // Create the input CVPixelBuffer
           
            let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                             width,
                                             height,
                                             kCVPixelFormatType_32BGRA,
                                             attributes as CFDictionary,
                                             &pbInput)

            // Sanity check
            if status != kCVReturnSuccess {
                return pbInput!
            }

            // Fill the input CVPixelBuffer with the content of the input CGImage
            CVPixelBufferLockBaseAddress(pbInput!, CVPixelBufferLockFlags(rawValue: 0))
            guard let context = CGContext(data: CVPixelBufferGetBaseAddress(pbInput!),
                                          width: width,
                                          height: height,
                                          bitsPerComponent: cgInput.bitsPerComponent,
                                          bytesPerRow: cgInput.bytesPerRow,
                                          space: cgInput.colorSpace!,
                                          bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
                                          return pbInput!
            }
            context.draw(cgInput, in: region)
            CVPixelBufferUnlockBaseAddress(pbInput!, CVPixelBufferLockFlags(rawValue: 0))
        return pbInput!
    }
    
    private func setupRecorder(timestamp: Double) {
        //assetWriterQueue.async {
        print("Initiated recorder")
        self._filename = UUID().uuidString
        let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(self._filename).mov")
        let writer = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
        let settings = CameraManager.shared.getVideoOutputSettings()
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings) // [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
        input.mediaTimeScale = CMTimeScale(bitPattern: 600)
        input.expectsMediaDataInRealTime = true
        input.transform = CGAffineTransform(rotationAngle: .pi/2)
        let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
        self._assetWriter = writer
        if self._assetWriter!.canAdd(input) {
            self._assetWriter?.add(input)
            
        }
        self._assetWriter?.startWriting()
        self._assetWriter?.startSession(atSourceTime: .zero)
        self._assetWriterInput = input
        self._adapter = adapter
        self._captureState = .capturing
        self._time = timestamp
        
    }
}

extension FrameManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        
        if let buffer = sampleBuffer.imageBuffer {
            
            self.current = buffer
            let cgImage = CGImage.create(from: buffer)
            if ( cgImage != nil) {
                if self.ortSession != nil {
                    let image = UIImage(cgImage: cgImage!)
                    let imageData = image.jpegData(compressionQuality: 0.1)!
                    let result = self.poseUtil.plotPose(inputData: imageData, ortSession: self.ortSession!)
                    self.poseImage = result
                    let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
                    switch self._captureState {
                    case .start:
                        self.setupRecorder(timestamp: timestamp)
                        self._captureState = .capturing
                    case .capturing:
                        if self._assetWriterInput?.isReadyForMoreMediaData == true {
                            let time = CMTime(seconds: timestamp - self._time, preferredTimescale: CMTimeScale(600))
                            /*
                            let pixelBuffer = CVPixelBuffer.from(result.jpegData(compressionQuality: 0.1)!,
                                                                 width: Int(result.size.width),
                                                                 height: Int(result.size.height),
                                                                 pixelFormat:kCVPixelFormatType_32BGRA)
                             */
                            //let pixelBuffer = convertUIImageToPixelBuffer(input: result)
                            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
                            self._adapter?.append(pixelBuffer!, withPresentationTime: time)
                            print("Processing video")
                        }
                        break
                    case .end:
                        self._captureState = .idle
                        guard self._assetWriterInput?.isReadyForMoreMediaData == true, self._assetWriter!.status != .failed else { break }
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(self._filename).mov")
                        
                        self._assetWriterInput?.markAsFinished()
                        self._assetWriter?.finishWriting { [weak self] in
                            print("Video successfully written at \(url.absoluteString)")
                            self?._captureState = .idle
                            self?._assetWriter = nil
                            self?._assetWriterInput = nil
                        }
                    default:
                        break
                    }
                }
            }
            
        }
        
    }
}
