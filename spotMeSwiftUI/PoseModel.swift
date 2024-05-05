//
//  PoseModel.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import Foundation
import onnxruntime_objc

class PoseModel {
    var ortEnv: ORTEnv?
    var ortSession: ORTSession?
    static let shared = PoseModel()
    private init() {
        initOrtSession()
        print("Pose model instantiated")
    }
    func initOrtSession() {
        
        guard let modelPath = Bundle.main.path(forResource: "yolov8n-pose-pre", ofType: "onnx") else {
            fatalError("Model file not found")
        }
        do {
            
            self.ortEnv = try ORTEnv(loggingLevel: ORTLoggingLevel.info)
            let ortSessionOptions = try ORTSessionOptions()
            let ortCoreMlSessionOptions = ORTCoreMLExecutionProviderOptions()
            try ortSessionOptions.appendCoreMLExecutionProvider(with: ortCoreMlSessionOptions)
            try ortSessionOptions.registerCustomOps(functionPointer: RegisterCustomOps) // Register the bridging-header in Build settings
            self.ortSession = try ORTSession(
                env: ortEnv!, modelPath: modelPath, sessionOptions: ortSessionOptions)
            
        } catch {
            NSLog("Model initialization error \(error)")
            
        }
    }
}
