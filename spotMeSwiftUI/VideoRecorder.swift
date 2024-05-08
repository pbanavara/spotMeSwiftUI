//
//  VideoRecorder.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 07/05/24.
//

import Foundation
import AVFoundation
import UIKit
import Combine

class VideoRecorder {
    private var _captureState: CaptureState?
    private var _filename = ""
    private var _time:Double = 0.0
    private var _assetWriter: AVAssetWriter?
    private var _assetWriterInput: AVAssetWriterInput?
    private var _adapter: AVAssetWriterInputPixelBufferAdaptor?
    private let frameManager = FrameManager.shared
    @Published var imageProcessStatus: String?
    private let assetWriterQueue:DispatchQueue = DispatchQueue(label :"cameraQueue", qos: .userInitiated)
    
    //static let shared = VideoRecorder()
    
    func setActionState(state: Bool) {
        switch state {
        case true:
            self._captureState = .end
        case false:
            self._captureState = .start
            self.writeVideo()
        }
        
    }
    
    func writeVideo() {
        frameManager.$imageTimeStamp
            .receive(on: RunLoop.current)
            .compactMap { imageTsData in
                //self.assetWriterQueue.async {
                let poseImg = imageTsData.image
                let timestamp = imageTsData.timestamp
                switch self._captureState {
                case .start:
                    self.setupRecorder(timestamp: timestamp!)
                    self._captureState = .capturing
                case .capturing:
                    if self._assetWriterInput?.isReadyForMoreMediaData == true {
                        let time = CMTime(seconds: timestamp! - self._time, preferredTimescale: CMTimeScale(600))
                        let pixelBuffer = CVPixelBuffer.from(poseImg!.jpegData(compressionQuality: 0.1)!,
                                                             width: Int(poseImg!.size.width),
                                                             height: Int(poseImg!.size.height),
                                                             pixelFormat:kCVPixelFormatType_32BGRA)
                        let appendStatus = self._adapter?.append(pixelBuffer, withPresentationTime: time)
                        print("Processing video")
                    }
                    break
                case .end:
                    print(self._assetWriter?.status.rawValue)
                    self._captureState = .idle
                    guard self._assetWriterInput?.isReadyForMoreMediaData == true, self._assetWriter!.status != .failed else { break }
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(self._filename).mov")
                    print("URL written \(url.absoluteString)")
                    self._assetWriterInput?.markAsFinished()
                    self._assetWriter?.finishWriting { [weak self] in
                        self?._captureState = .idle
                        self?._assetWriter = nil
                        self?._assetWriterInput = nil
                    }
                default:
                    break
                }
                //}
                return "Processing"
                
            }.assign(to: &$imageProcessStatus)
        
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
    //}
}

enum CaptureState {
    case idle, start, capturing, end
}

extension CVPixelBuffer {
    public static func from(_ data: Data, width: Int, height: Int, pixelFormat: OSType) -> CVPixelBuffer {
        data.withUnsafeBytes { buffer in
            var pixelBuffer: CVPixelBuffer!
            
            let result = CVPixelBufferCreate(kCFAllocatorDefault, width, height, pixelFormat, nil, &pixelBuffer)
            guard result == kCVReturnSuccess else { fatalError() }
            
            CVPixelBufferLockBaseAddress(pixelBuffer, [])
            defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
            
            var source = buffer.baseAddress!
            
            for plane in 0 ..< CVPixelBufferGetPlaneCount(pixelBuffer) {
                let dest      = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, plane)
                let height      = CVPixelBufferGetHeightOfPlane(pixelBuffer, plane)
                let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, plane)
                let planeSize = height * bytesPerRow
                
                memcpy(dest, source, planeSize)
                source += planeSize
            }
            
            return pixelBuffer
        }
    }
}
