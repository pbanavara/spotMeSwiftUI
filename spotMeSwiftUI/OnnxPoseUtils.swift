//
//  OnnxPoseUtils.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 26/04/24.
//

import Foundation
import SwiftUI
import onnxruntime_objc
import UIKit
import AVFoundation

/**
 * This is a singleton observable object that processes an UIImage and renders the detected pose points on the said image.
 *  It is key to use the correct model for the said purpose. Use the [Model generation] (https://onnxruntime.ai/docs/tutorials/mobile/pose-detection.html)
 *  It is also key to register the customOps function using the BridgingHeader
 */
class OnnxPoseUtils : NSObject, ObservableObject {
    @Published var poseImage: UIImage?
    @Published var hingeAngles: Dictionary<String, Double> = Dictionary()
    @Published var bodyInPosition: Bool = false
    
    //let videoManager = VideoRecordManager.shared
    static let sharedOnnx = OnnxPoseUtils()
    var poseToJoints: Dictionary<String, Array<String>> = Dictionary()
    let bodyPoses = BodyPoses()
    
    private override init() {
        super.init()
    }
    
    func plotPose(inputData: Data, ortSession: ORTSession, workoutType: String) {
        do {
            //let inputData = image.pngData()!
            let inputDataLength = inputData.count
            let inputShape = [NSNumber(integerLiteral: inputDataLength)]
            let inputTensor = try ORTValue(tensorData: NSMutableData(data: inputData), elementType:ORTTensorElementDataType.uInt8, shape:inputShape)
            let inputNames = try ortSession.inputNames()    // The input names should match the model input names. Visualize the model in Netron
            let outputNames = try ortSession.outputNames()  // Check the model outnames in Netron
            let outputs = try ortSession.run(
                withInputs: [inputNames[0]: inputTensor], outputNames: Set(outputNames), runOptions: nil)
            
            guard let outputTensor = outputs[outputNames[0]] else {
                fatalError("Failed to get model keypoint output from inference.")
            }
            self.poseImage =  try convertOutputTensorToImage(opTensor: outputTensor,
                                                             inputImageData: inputData,
                                                             workoutType: workoutType)
            
        } catch {
            print(error)
        }
    }
    
    private func convertOutputTensorToImage(opTensor: ORTValue,
                                            inputImageData: Data,
                                            workoutType: String) throws -> UIImage{
        /**
         Helper function to convert the output tensor into an image with the bounding box and keypoint data.
         */
        let output = try opTensor.tensorData()
        
        let image:UIImage = UIImage(data: inputImageData) ?? UIImage()
        let devOrientation = UIDevice.current.orientation
        if devOrientation == .faceUp || devOrientation == .faceDown {
            return image
        }
        var arr2 = Array<Float32>(repeating: 0, count: output.count/MemoryLayout<Float32>.stride)   // Do not change the datatype Float32
        _ = arr2.withUnsafeMutableBytes { output.copyBytes(to: $0) }
        
        if (arr2.count > 0) {
            var keypoints:[Float32] = Array()
            // 57 is hardcoded based on the keypoints returned from the model. Refer to the Netron visualisation for the output shape
            for i in stride(from: arr2.count-57, to: arr2.count, by: 1) {
                keypoints.append(arr2[i])
            }
            let box = keypoints[0..<4] // The first 4 points are the bounding box co-ords.
            // Refer yolov8_pose_e2e.py run_inference method under the https://onnxruntime.ai/docs/tutorials/mobile/pose-detection.html
            let personConfidence = keypoints[4]
            let half_w = box[2] / 2
            let half_h = box[3] / 2
            let x = Double(box[0] - half_w)
            let y = Double(box[1] - half_h)
            let rect = CGRect(x: x, y: y, width: Double(half_w * 2), height: Double(half_h * 2))
            
            let keypointsWithoutBoxes = Array(keypoints[6..<keypoints.count]) // Based on 17 keypoints and 3 entries per keypoint x,y,confidence
            
            
            return drawKeyPointsOnImage(image: image, rectangle: rect,
                                        keypoints: keypointsWithoutBoxes,
                                        workoutType: workoutType)
        } else {
            return image
        }
    }
    
    
    private func drawKeyPointsOnImage(image: UIImage, rectangle:CGRect,
                                      keypoints: [Float32],
                                      workoutType: String) -> UIImage {
        /**
         Helper function takes an input image and a boundding box CGRect along with the keypoints data to return a new image with the rect and keypoints drawn/
         TODO: // Optimize on generating a new image instead paint the data on the same image. iOS experts to chime in.
         
         */
        //Skipping the rectangle
        return drawPoseLines(image: image, keypoints: keypoints, workoutType: workoutType)
        
    }
    
    func drawBodyLines(bodyArray: Array<BodyPart>,
                       context: CGContext,
                       keyPoints: [Float32],
                       color: UIColor) {
        for i in 0...(bodyArray.count-2) {
            drawSpecificLine(context: context,
                             kp1_x: keyPoints[bodyArray[i].xIndex],
                             kp1_y: keyPoints[bodyArray[i].yIndex],
                             kp2_x: keyPoints[bodyArray[i+1].xIndex],
                             kp2_y: keyPoints[bodyArray[i+1].yIndex],
                             color: color,
                             lineWidth: 8.0)
        }
        
    }
    
    func calculateAndRenderHipHinge(keyPoints: [Float32], bodyArray: Array<BodyPart>, context: CGContext, image: UIImage, angleRange: [Double]) {
        let left_knee_hip_angle_x = keyPoints[bodyPoses.leftKnee.xIndex] - keyPoints[bodyPoses.leftHip.xIndex]
        let left_knee_hip_angle_y = keyPoints[bodyPoses.leftKnee.yIndex] - keyPoints[bodyPoses.leftHip.yIndex]
        
        let left_hip_shoulder_angle_x =  keyPoints[bodyPoses.leftShoulder.xIndex] - keyPoints[bodyPoses.leftHip.xIndex]
        let left_hip_shoulder_angle_y = keyPoints[bodyPoses.leftShoulder.yIndex] - keyPoints[bodyPoses.leftHip.yIndex]
        
        // Calculate Hip Hinge
        //let hip_hinge = (atan2(right_knee_hip_angle_x, right_knee_hip_angle_y) - atan2(right_hip_shoulder_angle_x, right_hip_shoulder_angle_y)) * 57.2958
        let hip_hinge = abs(Double((atan2(left_knee_hip_angle_x, left_knee_hip_angle_y) - atan2(left_hip_shoulder_angle_x, left_hip_shoulder_angle_y)) * 57.2958)).rounded()
        self.hingeAngles[BodyAngleContants.HIP_HINGE_ANGLE] = hip_hinge
        
        // Write the hip hinge into text
        
        
        if (hip_hinge >= angleRange.first! && hip_hinge <= angleRange.last!) && calculateKneeHinge(keyPoints: keyPoints, bodyArray: bodyArray, context: context, image: image){
            drawBodyLines(bodyArray: bodyArray, context: context, keyPoints: keyPoints, color: UIColor.green)
            //textToSpeech(str: "Hip hinge/angle perfect, hold this position and bend your knees till you reach the kettlebell. Get up straight to finish.")
            drawTextInImage(hinge: Double(hip_hinge),
                            hingeDesc: "Perfect hip hinge",
                            image: image,
                            textColor: UIColor.green,
                            yOffset: 0.0)
        } else {
            drawTextInImage(hinge: Double(hip_hinge),
                            hingeDesc: "Hip hinge",
                            image: image,
                            textColor: UIColor.white,
                            yOffset: 0.0)
        }
    }
    
    func calculateAndRenderElbowHinge(keyPoints: [Float32], bodyArray: Array<BodyPart>, context: CGContext, image: UIImage) {
        let leftElbowAngleX = keyPoints[bodyPoses.leftWrist.xIndex] - keyPoints[bodyPoses.leftElbow.xIndex]
        let leftElbowAngleY = keyPoints[bodyPoses.leftWrist.yIndex] - keyPoints[bodyPoses.leftElbow.yIndex]
        
        let leftElbowWristAngleX =  keyPoints[bodyPoses.leftShoulder.xIndex] - keyPoints[bodyPoses.leftElbow.xIndex]
        let leftElbowWristAngleY = keyPoints[bodyPoses.leftShoulder.yIndex] - keyPoints[bodyPoses.leftElbow.yIndex]
        
        // Calculate Hip Hinge
        //let hip_hinge = (atan2(right_knee_hip_angle_x, right_knee_hip_angle_y) - atan2(right_hip_shoulder_angle_x, right_hip_shoulder_angle_y)) * 57.2958
        let hinge = abs(Double((atan2(leftElbowAngleX, leftElbowAngleY) - atan2(leftElbowWristAngleX, leftElbowWristAngleY)) * 57.2958)).rounded()
        self.hingeAngles[BodyAngleContants.ELBOW_ANGLE] = hinge
        
        // Write the hip hinge into text
        
        
        if (hinge >= CorrectElbowHingeConstants.CORRECT_ELBOW_L && hinge <= CorrectElbowHingeConstants.CORRECT_ELBOW_R) {
            drawBodyLines(bodyArray: bodyArray, context: context, keyPoints: keyPoints, color: UIColor.green)
            drawTextInImage(hinge: Double(hinge),
                            hingeDesc: "Perfect elbow hinge",
                            image: image,
                            textColor: UIColor.green,
                            yOffset: 0.0)
        } else {
            drawTextInImage(hinge: Double(hinge),
                            hingeDesc: "Elbow hinge",
                            image: image,
                            textColor: UIColor.white,
                            yOffset: 0.0)
        }
    }
    
    
    ///
    /// This method returns a boolean because it is used as an inner function for calculating hip hinge
    private func calculateKneeHinge(keyPoints: [Float32], bodyArray: Array<BodyPart>, context: CGContext, image: UIImage) -> Bool {
        let leftKneeX = keyPoints[bodyPoses.leftAnkle.xIndex] - keyPoints[bodyPoses.leftKnee.xIndex]
        let leftKneeY = keyPoints[bodyPoses.leftAnkle.yIndex] - keyPoints[bodyPoses.leftKnee.yIndex]
        
        let leftAnkleX =  keyPoints[bodyPoses.leftHip.xIndex] - keyPoints[bodyPoses.leftKnee.xIndex]
        let leftAnkleY = keyPoints[bodyPoses.leftHip.yIndex] - keyPoints[bodyPoses.leftKnee.yIndex]
        
        // Calculate Hip Hinge
        //let hip_hinge = (atan2(right_knee_hip_angle_x, right_knee_hip_angle_y) - atan2(right_hip_shoulder_angle_x, right_hip_shoulder_angle_y)) * 57.2958
        let hinge = abs(Double((atan2(leftKneeX, leftKneeY) - atan2(leftAnkleX, leftAnkleY)) * 57.2958)).rounded()
        self.hingeAngles[BodyAngleContants.KNEE_HIP_ANGLE] = hinge
        
        // Write the hip hinge into text
        
        
        if (hinge >= CorrectKneeHingeConstants.CORRECT_KNEE_L && hinge <= CorrectKneeHingeConstants.CORRECT_KNEE_R) {
            drawTextInImage(hinge: Double(hinge),
                            hingeDesc: "Perfect Knee hinge",
                            image: image,
                            textColor: UIColor.green,
                            yOffset: 50.0)
            return true
        } else {
            drawTextInImage(hinge: Double(hinge),
                            hingeDesc: "Knee hinge",
                            image: image,
                            textColor: UIColor.white,
                            yOffset: 50.0)
            return false
        }
    }
    
    func drawPoseLines(image: UIImage, keypoints: [Float32], workoutType: String) -> UIImage {
        let imageSize = image.size
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let img = renderer.image(actions: { imgContext in
            let context = imgContext.cgContext
            image.draw(at: CGPoint.zero)
            switch workoutType {
            case KBWorkoutConstants.KB_DEAD_LIFT:
                if let deadLiftArray = bodyPoses.bodyPosesMap[KBWorkoutConstants.KB_DEAD_LIFT] {
                    let newArray = deadLiftArray.filter({
                        keypoints[$0.confIndex] > 0.8
                    })
                    if newArray.count == deadLiftArray.count {
                        drawBodyLines(bodyArray: deadLiftArray, context: context, keyPoints: keypoints, color: UIColor.white)
                        calculateAndRenderHipHinge(keyPoints: keypoints,
                                                   bodyArray: deadLiftArray,
                                                   context: context,
                                                   image: image,
                                                   angleRange: [CorrectHipHingeConstants.CORRECT_HIP_L, CorrectHipHingeConstants.CORRECT_HIP_R])
                        bodyInPosition = true
                    } else {
                        bodyInPosition = false
                    }
                    
                }
            case KBWorkoutConstants.KB_SQUAT:
                if let squatArray = bodyPoses.bodyPosesMap[KBWorkoutConstants.KB_SQUAT] {
                    let newArray = squatArray.filter({
                        keypoints[$0.confIndex] > 0.8
                    })
                    if newArray.count == squatArray.count {
                        drawBodyLines(bodyArray: squatArray, context: context, keyPoints: keypoints, color: UIColor.white)
                        calculateAndRenderHipHinge(keyPoints: keypoints,
                                                   bodyArray: squatArray,
                                                   context: context,
                                                   image: image,
                                                   angleRange: [CorrectHipHingeConstants.CORRECT_HIP_L, CorrectHipHingeConstants.CORRECT_HIP_R])
                        bodyInPosition = true
                    } else {
                        bodyInPosition = false
                    }
                }
            case KBWorkoutConstants.KB_SWING:
                if let swingArray = bodyPoses.bodyPosesMap[KBWorkoutConstants.KB_SWING] {
                    let newArray = swingArray.filter({
                        keypoints[$0.confIndex] > 0.8
                    })
                    if newArray.count == swingArray.count {
                        drawBodyLines(bodyArray: swingArray, context: context, keyPoints: keypoints, color: UIColor.white)
                        calculateAndRenderHipHinge(keyPoints: keypoints,
                                                   bodyArray: swingArray,
                                                   context: context,
                                                   image: image,
                                                   angleRange: [CorrectSwingHipHingeConstants.CORRECT_HIP_L, CorrectSwingHipHingeConstants.CORRECT_HIP_R])
                        _ = calculateKneeHinge(keyPoints: keypoints, bodyArray: swingArray, context: context, image: image)
                        bodyInPosition = true
                    } else {
                        bodyInPosition = false
                    }
                }
            case KBWorkoutConstants.KB_SHOULDER:
                if let shoulderArray = bodyPoses.bodyPosesMap[KBWorkoutConstants.KB_SHOULDER] {
                    let newArray = shoulderArray.filter({
                        keypoints[$0.confIndex] > 0.8
                    })
                    if newArray.count == shoulderArray.count {
                        drawBodyLines(bodyArray: shoulderArray, context: context, keyPoints: keypoints, color: UIColor.white)
                        bodyInPosition = true
                    } else {
                        bodyInPosition = false
                    }
                }
            case KBWorkoutConstants.BAR_DEAD_LIFT:
                if let barDlArray = bodyPoses.bodyPosesMap[KBWorkoutConstants.KB_DEAD_LIFT] {
                    let newArray = barDlArray.filter({
                        keypoints[$0.confIndex] > 0.8
                    })
                    if newArray.count == barDlArray.count {
                        drawBodyLines(bodyArray: barDlArray, context: context, keyPoints: keypoints, color: UIColor.white)
                        calculateAndRenderHipHinge(keyPoints: keypoints,
                                                   bodyArray: barDlArray,
                                                   context: context,
                                                   image: image,
                                                   angleRange: [CorrectBarDlHipHingeConstants.CORRECT_HIP_L, CorrectBarDlHipHingeConstants.CORRECT_HIP_R])
                        bodyInPosition = true
                    } else {
                        bodyInPosition = false
                    }
                }
            case KBWorkoutConstants.BAR_SQUAT:
                if let barSquatArray = bodyPoses.bodyPosesMap[KBWorkoutConstants.BAR_SQUAT] {
                    let newArray = barSquatArray.filter({
                        keypoints[$0.confIndex] > 0.8
                    })
                    if newArray.count == barSquatArray.count {
                        drawBodyLines(bodyArray: newArray, context: context, keyPoints: keypoints, color: UIColor.white)
                        calculateAndRenderHipHinge(keyPoints: keypoints,
                                                   bodyArray: barSquatArray,
                                                   context: context,
                                                   image: image,
                                                   angleRange: [CorrectHipHingeConstants.CORRECT_HIP_L, CorrectHipHingeConstants.CORRECT_HIP_R])
                        bodyInPosition = true
                    } else {
                        bodyInPosition = false
                    }
                }
            case KBWorkoutConstants.BODYWEIGHT_PUSHUP:
                if let bodyArray = bodyPoses.bodyPosesMap[KBWorkoutConstants.BODYWEIGHT_PUSHUP] {
                    let newArray = bodyArray.filter({
                        keypoints[$0.confIndex] > 0.8
                    })
                    if newArray.count == bodyArray.count {
                        drawBodyLines(bodyArray: bodyArray, context: context, keyPoints: keypoints, color: UIColor.white)
                        calculateAndRenderElbowHinge(keyPoints: keypoints, bodyArray: bodyArray, context: context, image: image)
                        bodyInPosition = true
                    } else {
                        bodyInPosition = false
                    }
                }
            case KBWorkoutConstants.BAR_BENCH_PRESS:
                if let bodyArray = bodyPoses.bodyPosesMap[KBWorkoutConstants.BAR_BENCH_PRESS] {
                    let newArray = bodyArray.filter({
                        keypoints[$0.confIndex] > 0.8
                    })
                    if newArray.count == bodyArray.count {
                        drawBodyLines(bodyArray: bodyArray, context: context, keyPoints: keypoints, color: UIColor.white)
                        calculateAndRenderElbowHinge(keyPoints: keypoints, bodyArray: bodyArray, context: context, image: image)
                        bodyInPosition = true
                    } else {
                        bodyInPosition = false
                    }
                }
            default:
                return
            }
            
        })
        
        return img
    }
    
    func imageFromVideo(url: URL, at time: TimeInterval) async throws -> UIImage {
        let asset = AVURLAsset(url: url)
        
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        assetImageGenerator.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
        
        let cmTime = CMTime(seconds: time, preferredTimescale: 60)
        let thumbnailImage = try await assetImageGenerator.image(at: cmTime).image
        return UIImage(cgImage: thumbnailImage)
    }
    
    func drawTextInImage(hinge: Double, 
                         hingeDesc: String,
                         image: UIImage,
                         textColor: UIColor,
                         yOffset: CGFloat) {
        let textFont = UIFont(name: "Helvetica", size: 50)!
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ] as [NSAttributedString.Key : Any]
        let hip_text = hingeDesc + ":" + hinge.description + "º"
        let rect = CGRect(origin: CGPoint.zero, size: image.size).offsetBy(dx: 0.0, dy: yOffset)
        //let addTextRect = rect.offsetBy(dx: 0.0, dy: yOffset + 50.0)
        
        hip_text.draw(in: rect, withAttributes: textFontAttributes)
        //correctPosition.draw(in: addTextRect, withAttributes: textFontAttributes)
    }
    
    func drawSpecificLine(context: CGContext, kp1_x: Float32, kp1_y: Float32,
                          kp2_x: Float32, kp2_y: Float32, color: UIColor, lineWidth: Double) {
        context.setLineWidth(lineWidth)
        context.setStrokeColor(color.cgColor)
        context.move(to: CGPoint(x: Double(kp1_x), y: Double(kp1_y)))
        context.addLine(to: CGPoint(x: Double(kp2_x), y: Double(kp2_y)))
        let rectangle = CGRect(x: Int(kp1_x), y: Int(kp1_y), width: 20, height: 20).offsetBy(dx: -5.0, dy: 0)
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: rectangle)
        context.move(to: CGPoint(x: Double(kp1_x), y: Double(kp1_y)))
        context.addLine(to: CGPoint(x: Double(kp2_x), y: Double(kp2_y)))
        context.strokePath()
    }
    
}


