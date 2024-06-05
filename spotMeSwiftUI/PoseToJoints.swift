//
//  PoseToJoints.swift
//  CallindraFitness
//
//  Created by Pradeep Banavara on 03/06/24.
//

import Foundation

struct BodyPart {
    var xIndex = 0
    var yIndex = 0
    var confIndex = 0
    
    init(xIndex: Int, yIndex: Int, confIndex: Int) {
        self.xIndex = xIndex
        self.yIndex = yIndex
        self.confIndex = confIndex
    }
}
struct BodyPoses {
    var bodyPosesMap: Dictionary<String, Array<BodyPart>> = Dictionary()
   
    //Draw specific line - Right shoulder to right hip
    /*
    let right_shoulder_x = keypoints[18]
    let right_shoulder_y = keypoints[19]
    let right_hip_x = keypoints[36]
    let right_hip_y = keypoints[37]
    drawSpecificLine(context: context, kp1_x: right_shoulder_x, kp1_y: right_shoulder_y, kp2_x: right_hip_x, kp2_y: right_hip_y, color: UIColor.black)
    
    Draw specific line - Right hip to right knee and right knee to right ankle
    let right_knee_x = keypoints[42]
    let right_knee_y = keypoints[43]
    drawSpecificLine(context: context, kp1_x: right_hip_x, kp1_y: right_hip_y, kp2_x: right_knee_x, kp2_y: right_knee_y, color: UIColor.blue)
    let right_ankle_x = keypoints[48]
    let right_ankle_y = keypoints[49]
    drawSpecificLine(context: context, kp1_x: right_knee_x, kp1_y: right_knee_y, kp2_x: right_ankle_x, kp2_y: right_ankle_y, color: UIColor.blue)
    let right_knee_hip_angle_x = right_knee_x - right_hip_x
    let right_knee_hip_angle_y = right_knee_y - right_hip_y
    
    let right_hip_shoulder_angle_x = right_hip_x - right_shoulder_x
    let right_hip_shoulder_angle_y = right_hip_y - right_shoulder_y
    */
    var leftShoulder: BodyPart = BodyPart(xIndex: 15, yIndex: 16, confIndex: 17)
    var leftHip: BodyPart = BodyPart(xIndex: 33, yIndex: 34, confIndex: 35)
    var leftKnee: BodyPart = BodyPart(xIndex: 39, yIndex: 40, confIndex: 41)
    var leftAnkle: BodyPart = BodyPart(xIndex: 45, yIndex: 46, confIndex: 47)
    
    var leftWrist: BodyPart = BodyPart(xIndex: 27, yIndex: 28, confIndex: 29)
    var leftElbow: BodyPart = BodyPart(xIndex: 21, yIndex: 22, confIndex: 23)
    var leftEar: BodyPart = BodyPart(xIndex: 9, yIndex: 10, confIndex: 11)

    init() {
        let deadLiftPose = initDeadLiftPose()
        let swingPose = initSwingPose()
        let shoulderPose = initShoulderPressPose()
        bodyPosesMap[KBWorkoutConstants.KB_DEAD_LIFT] = deadLiftPose
        bodyPosesMap[KBWorkoutConstants.KB_SWING] = swingPose
        bodyPosesMap[KBWorkoutConstants.KB_SHOULDER] = shoulderPose
    }
    
    func initDeadLiftPose() -> Array<BodyPart> {
        var deadLiftPose: Array<BodyPart> = []
        deadLiftPose.append(leftShoulder)
        deadLiftPose.append(leftHip)
        deadLiftPose.append(leftKnee)
        return deadLiftPose
    }
    
    func initSwingPose() -> Array<BodyPart> {
        var swingPose: Array<BodyPart> = []
        swingPose.append(leftWrist)
        swingPose.append(leftElbow)
        swingPose.append(leftShoulder)
        swingPose.append(leftHip)
        swingPose.append(leftKnee)
        swingPose.append(leftAnkle)
        return swingPose
    }
    
    func initShoulderPressPose() -> Array<BodyPart> {
        var shoulderPressPose: Array<BodyPart> = []
        shoulderPressPose.append(leftWrist)
        shoulderPressPose.append(leftElbow)
        shoulderPressPose.append(leftShoulder)
        shoulderPressPose.append(leftEar)
        return shoulderPressPose
    }
}
