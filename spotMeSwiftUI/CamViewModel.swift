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
    private let frameManager = FrameManager.shared
    
    init() {
        getPoseImage()
    }
    func getPoseImage() {
        frameManager.$poseImage
            .receive(on: RunLoop.main)
            .compactMap { image in
                return image?.cgImage

            }.assign(to: &$poseImage)
    }
}
