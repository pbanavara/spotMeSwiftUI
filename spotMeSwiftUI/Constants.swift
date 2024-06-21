//
//  Constants.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 18/05/24.
//

import Foundation

enum BodyAngleContants {
    static let HIP_HINGE_ANGLE = "hipHingeAngle"
    static let KNEE_HIP_ANGLE = "kneeHipAngle"
    static let ELBOW_ANGLE = "elbowAngle"
    
}

enum AudioProcessConstants {
    static var WAIT_UNTIL_PREV_SPEECH_FINISHED = false
}

enum BackendResponseConstants {
    static let BACKEND_JSON_RESPONSE = "response"
}

enum CorrectHipHingeConstants {
    static let CORRECT_HIP_L = 80.0
    static let CORRECT_HIP_R = 100.0
}

enum CorrectBarDlHipHingeConstants {
    static let CORRECT_HIP_L = 60.0
    static let CORRECT_HIP_R = 65.0
}

enum CorrectSwingHipHingeConstants {
    static let CORRECT_HIP_L = 80.0
    static let CORRECT_HIP_R = 90.0
}

enum CorrectElbowHingeConstants {
    static let CORRECT_ELBOW_L = 40.0
    static let CORRECT_ELBOW_R = 50.0
}

enum CorrectKneeHingeConstants {
    static let CORRECT_KNEE_L = 120.0
    static let CORRECT_KNEE_R = 140.0
}
