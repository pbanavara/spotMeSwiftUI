//
//  VideoRecordManager.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 13/05/24.
//

import Foundation
import UIKit
import AVFoundation

class VideoRecordManager: ObservableObject {
    private var _captureState: CaptureState?
    private var poseUtils: OnnxPoseUtils = OnnxPoseUtils.shared
    @Published var image: UIImage?
    private var _filename = ""
    private var _time:Double = 0.0
    private var _assetWriter: AVAssetWriter?
    private var _assetWriterInput: AVAssetWriterInput?
    private var _adapter: AVAssetWriterInputPixelBufferAdaptor?
    
    init() {
        startProcessing()
    }
    
    enum CaptureState {
        case idle, start, capturing, end
    }
    
    func bufferFromImage(image: UIImage) -> CVPixelBuffer? {
      let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
      var pixelBuffer : CVPixelBuffer?
      let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
      guard (status == kCVReturnSuccess) else {
        return nil
      }

      CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
      let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

      let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
      let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

      context?.translateBy(x: 0, y: image.size.height)
      context?.scaleBy(x: 1.0, y: -1.0)

      UIGraphicsPushContext(context!)
      image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      UIGraphicsPopContext()
      CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

      return pixelBuffer
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
        input.transform = CGAffineTransform(rotationAngle: 90.0)
        let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
        self._assetWriter = writer
        if self._assetWriter!.canAdd(input) {
            self._assetWriter?.add(input)
            
        }
        self._assetWriter?.startWriting()
        // Ballpark delay to accomodate initial black screen
        let startTime = CMTimeMakeWithSeconds(3.0, preferredTimescale: 1000000000)
        self._assetWriter?.startSession(atSourceTime: startTime)
        self._assetWriterInput = input
        self._adapter = adapter
        self._captureState = .capturing
        self._time = timestamp
        
    }
    
    func setActionState(state: Bool) {
        switch state {
        case true:
            self._captureState = .end
        case false:
            self._captureState = .start
            
        }
    }
    
    func startProcessing() {
        poseUtils.$poseImage.receive(on: RunLoop.main)
            .compactMap { image in
                guard let image = image else { return image}
                self.recordVideo(result: image)
                return image
            }.assign(to: &$image)
    }
    
    func recordVideo(result: UIImage) {
        let timestamp = CACurrentMediaTime()
        switch self._captureState {
        case .start:
            self.setupRecorder(timestamp: timestamp)
            self._captureState = .capturing
        case .capturing:
            if self._assetWriterInput?.isReadyForMoreMediaData == true {
                let time = CMTime(seconds: timestamp - self._time, preferredTimescale: CMTimeScale(600))
                let pixelBuffer = bufferFromImage(image: result)
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
