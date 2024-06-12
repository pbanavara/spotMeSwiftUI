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
    @Published var poseImage: CGImage?
    @Published var hipAngle: Double?
    @Published var bodyInPosition: Bool?
    private let frameManager: FrameManager
    private let poseUtils = OnnxPoseUtils.sharedOnnx
    private let agent = Agent.shared
    
    init() {
        agent.processVideoOutputText()
        frameManager = FrameManager.shared
        getPoseImage()
        
    }
    
    func getPoseImage() {
        poseUtils.$poseImage
            .receive(on: RunLoop.main)
            .compactMap { image in
                return image?.cgImage

            }.assign(to: &$poseImage)
        
        poseUtils.$bodyInPosition
            .receive(on: RunLoop.main)
            .compactMap { value in
                return value

            }.assign(to: &$bodyInPosition)
    }
    
}
