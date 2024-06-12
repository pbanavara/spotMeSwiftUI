//
//  FrameManager.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import AVFoundation
import UIKit

class FrameManager:NSObject {
    static let shared = FrameManager()
    let coachViewModel = CoachViewModel.shared
    let poseUtil = OnnxPoseUtils.sharedOnnx
    var ortSession: ORTSession?
    @Published var current: CVPixelBuffer?
    @Published var poseImage:UIImage?
    
    struct ImageTimeStamp {
        var image: UIImage?
        var timestamp: Double?
    }
    
    let videoOutputQueue = DispatchQueue(label: "videoOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    private override init() {
        super.init()
        CameraManager.shared.configure()
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
            
            self.current = buffer
            if let cgImage = CGImage.create(from: buffer) {
                if self.ortSession != nil {
                    let imageOrientation: UIImage.Orientation
                    switch UIDevice.current.orientation {
                    case .portrait:
                        imageOrientation = .up
                    case .portraitUpsideDown:
                        imageOrientation = .down
                    case .landscapeLeft:
                        imageOrientation = .leftMirrored
                    case .landscapeRight:
                        imageOrientation = .rightMirrored
                    case .unknown:
                        print("The device orientation is unknown, the predictions may be affected")
                        fallthrough
                    default:
                        imageOrientation = .up
                    }
                    let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: imageOrientation)
                    
                    //Fiddle around with jpegquality until you have a proper number using 0.5 for now
                    let imageData = image.jpegData(compressionQuality: 0.5)
                    ///Following the pub-sub pattern, just invoke the plotPose method
                    ///poseUtil conforms to observable protocol any model/view can observe and take action on the image
                    
                    self.poseUtil.plotPose(inputData: imageData!,
                                           ortSession: self.ortSession!,
                                           workoutType: coachViewModel.selectedWorkout)
                    
                
                }
            }
            
        }
        
    }
}
