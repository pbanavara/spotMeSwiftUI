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
    @Published var current: CVPixelBuffer?
    @Published var poseImage:UIImage?
    
    let videoOutputQueue = DispatchQueue(label: "videoOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    private override init() {
        super.init()
        CameraManager.shared.set(self, queue: videoOutputQueue)
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
            let ortSession = PoseModel.shared.ortSession
            if ortSession != nil {
                let poseUtil = OnnxPoseUtils()
                let image = UIImage(cgImage: cgImage!)
                let imageData = image.jpegData(compressionQuality: 0.1)!
                self.poseImage = poseUtil.plotPose(inputData: imageData, ortSession: ortSession!)
            }
        }
        
      //}
    }
  }
}
