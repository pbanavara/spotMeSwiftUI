//
//  CamViewModel.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import Foundation
import CoreImage
import UIKit

class CamViewModel: ObservableObject {
    @Published var frame: CGImage?
    @Published var keyPoints: [Float32]?
    private let frameManager = FrameManager.shared
    init() {
        setupSubscriptions()
        getPoseKeyPoints()
    }
    func setupSubscriptions() {
        frameManager.$current
            .receive(on: RunLoop.main)
            .compactMap { buffer in
                let cgImage = CGImage.create(from: buffer)
                /*
                var result: CGImage?
                var imageData: Data?
                
                if ( cgImage != nil) {
                    let ortSession = PoseModel.shared.ortSession
                    if ortSession != nil {
                        let poseUtil = OnnxPoseUtils()
                        //DispatchQueue.global(qos: .userInitiated).async {
                            let image = UIImage(cgImage: cgImage!)
                            imageData = image.jpegData(compressionQuality: 0.1)
                        //}
                        //guard let imageData = imageData else { return result }
                        result = poseUtil.plotPose(inputData: imageData!, ortSession: ortSession!).cgImage
                    }
                }
                 */
                return cgImage
            }
            .assign(to: &$frame)
    }
    
    func getPoseKeyPoints() {
        frameManager.$currentKeyPoints
            .receive(on: RunLoop.main)
            .compactMap { keyPoints in
                return keyPoints

            }.assign(to: &$keyPoints)
    }
}
