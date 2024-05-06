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
    
    let videoOutputQueue = DispatchQueue(label: "videoOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    private override init() {
        super.init()
        CameraManager.shared.set(self, queue: videoOutputQueue)
        DispatchQueue.global(qos: .userInitiated).async {
            self.ortSession = PoseModel.shared.ortSession
        }
    }
}

extension FrameManager: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    if let buffer = sampleBuffer.imageBuffer {
      //DispatchQueue.main.async {
        self.current = buffer
        let cgImage = CGImage.create(from: buffer)
        
        if ( cgImage != nil) {
            if ortSession != nil {
                let image = UIImage(cgImage: cgImage!)
                let imageData = image.jpegData(compressionQuality: 0.1)!
                self.poseImage = poseUtil.plotPose(inputData: imageData, ortSession: ortSession!)
            }
        }
        
      //}
    }
  }
}
