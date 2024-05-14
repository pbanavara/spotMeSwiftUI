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
    
    private let frameManager = FrameManager.shared
    private let videoRecManager = VideoRecordManager()
    
    init() {
        getPoseImage()
    }
    
    func getPoseImage() {
        videoRecManager.$image
            .receive(on: RunLoop.main)
            .compactMap { image in
                return image?.cgImage

            }.assign(to: &$poseImage)
    }
    
}
