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
    
    //let videoManager = VideoRecordManager.shared
    static let sharedOnnx = OnnxPoseUtils()
    
    private override init() {
        super.init()
    }
    
    func getPoseKeyPoints(inputData: Data, ortSession: ORTSession) -> [Float32]{
        
        var keypoints:[Float32] = [0.0]
        do {
            let inputDataLength = inputData.count
            let inputShape = [NSNumber(integerLiteral: inputDataLength)]
            let inputTensor = try ORTValue(tensorData: NSMutableData(data: inputData), elementType:ORTTensorElementDataType.uInt8, shape:inputShape)
            let inputNames = try ortSession.inputNames()    // The input names should match the model input names. Visualize the model in Netron
            let outputNames = try ortSession.outputNames()  // Check the model outnames in Netron
            let startTime = CACurrentMediaTime()
            let outputs = try ortSession.run(
                withInputs: [inputNames[0]: inputTensor], outputNames: Set(outputNames), runOptions: nil)
            
            guard let outputTensor = outputs[outputNames[0]] else {
                fatalError("Failed to get model keypoint output from inference.")
            }
            print("Getting output tensor \(CACurrentMediaTime() - startTime)")
            keypoints = convertOutputTensorToKeyPoints(opTensor: outputTensor, inputImageData: inputData)
            print("Getting keypoints \(CACurrentMediaTime() - startTime)")
        } catch {
            print(error)
        }
        return keypoints
    }
    
    
    func convertOutputTensorToKeyPoints(opTensor: ORTValue, inputImageData: Data) -> [Float32] {
        var keypoints:[Float32] = [0.0]
        do {
            let output = try opTensor.tensorData()
            var arr2 = Array<Float32>(repeating: 0, count: output.count/MemoryLayout<Float32>.stride)   // Do not change the datatype Float32
            _ = arr2.withUnsafeMutableBytes { output.copyBytes(to: $0) }
            
            if (arr2.count > 0) {
                keypoints.removeAll()
                // 57 is hardcoded based on the keypoints returned from the model. Refer to the Netron visualisation for the output shape
                for i in stride(from: arr2.count-57, to: arr2.count, by: 1) {
                    keypoints.append(arr2[i])
                }
            }
        } catch {
            NSLog(error.localizedDescription)
        }
        return keypoints
    }
    
    func plotPose(inputData: Data, ortSession: ORTSession) {
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
            self.poseImage =  try convertOutputTensorToImage(opTensor: outputTensor, inputImageData: inputData)
            
        } catch {
            print(error)
        }
    }
    
    private func convertOutputTensorToImage(opTensor: ORTValue, inputImageData: Data) throws -> UIImage{
        /**
         Helper function to convert the output tensor into an image with the bounding box and keypoint data.
         */
        
        let output = try opTensor.tensorData()
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
            let half_w = box[2] / 2
            let half_h = box[3] / 2
            let x = Double(box[0] - half_w)
            let y = Double(box[1] - half_h)
            let rect = CGRect(x: x, y: y, width: Double(half_w * 2), height: Double(half_h * 2))
            let image:UIImage = UIImage(data: inputImageData) ?? UIImage()
            let keypointsWithoutBoxes = Array(keypoints[6..<keypoints.count]) // Based on 17 keypoints and 3 entries per keypoint x,y,confidence
            return drawKeyPointsOnImage(image: image, rectangle: rect, keypoints: keypointsWithoutBoxes)
        } else {
            // Do not record if no pose objects found
            //AvideoManager.pauseRecording()
            return UIImage(data: inputImageData)!
        }
    }
    
    
    private func drawKeyPointsOnImage(image: UIImage, rectangle:CGRect, keypoints: [Float32]) -> UIImage {
        /**
         Helper function takes an input image and a boundding box CGRect along with the keypoints data to return a new image with the rect and keypoints drawn/
         TODO: // Optimize on generating a new image instead paint the data on the same image. iOS experts to chime in.
         
         */
        var image = image
        let imageSize = image.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        image.draw(at: CGPoint.zero)
        UIColor.red.setFill()
        UIColor.red.setStroke()
        UIRectFrame(rectangle)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.blue.cgColor)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return drawPoseLines(image: image, keypoints: keypoints)
        
    }
    
    /// Placeholder method to draw lines for poses.
    private func drawPoseLines(image: UIImage, keypoints: [Float32]) -> UIImage {
        var image = image
        let imageSize = image.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        image.draw(at: CGPoint.zero)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        //Draw specific line - left shoulder to left hip
        let left_shoulder_x = keypoints[15]
        let left_shoulder_y = keypoints[16]
        let left_hip_x = keypoints[33]
        let left_hip_y = keypoints[34]
        drawSpecificLine(context: context, kp1_x: left_shoulder_x, kp1_y: left_shoulder_y, kp2_x: left_hip_x, kp2_y: left_hip_y, color: UIColor.white, lineWidth: 3.0)
        //Draw specific line - left knee to left ankle
        let left_knee_x = keypoints[39]
        let left_knee_y = keypoints[40]
        drawSpecificLine(context: context, kp1_x: left_hip_x, kp1_y: left_hip_y, kp2_x: left_knee_x, kp2_y: left_knee_y, color: UIColor.white, lineWidth: 3.0)
        //Draw specific line - left knee to left ankle
        let left_ankle_x = keypoints[45]
        let left_ankle_y = keypoints[46]
        drawSpecificLine(context: context, kp1_x: left_knee_x, kp1_y: left_knee_y, kp2_x: left_ankle_x, kp2_y: left_ankle_y, color: UIColor.white, lineWidth: 3.0)
        
        //Draw specific line - Right shoulder to right hip
        let right_shoulder_x = keypoints[18]
        let right_shoulder_y = keypoints[19]
        let right_hip_x = keypoints[36]
        let right_hip_y = keypoints[37]
        //drawSpecificLine(context: context, kp1_x: right_shoulder_x, kp1_y: right_shoulder_y, kp2_x: right_hip_x, kp2_y: right_hip_y, color: UIColor.black)
        
        //Draw specific line - Right hip to right knee and right knee to right ankle
        let right_knee_x = keypoints[42]
        let right_knee_y = keypoints[43]
        //drawSpecificLine(context: context, kp1_x: right_hip_x, kp1_y: right_hip_y, kp2_x: right_knee_x, kp2_y: right_knee_y, color: UIColor.blue)
        let right_ankle_x = keypoints[48]
        let right_ankle_y = keypoints[49]
        //drawSpecificLine(context: context, kp1_x: right_knee_x, kp1_y: right_knee_y, kp2_x: right_ankle_x, kp2_y: right_ankle_y, color: UIColor.blue)
        let right_knee_hip_angle_x = right_knee_x - right_hip_x
        let right_knee_hip_angle_y = right_knee_y - right_hip_y
        
        let right_hip_shoulder_angle_x = right_hip_x - right_shoulder_x
        let right_hip_shoulder_angle_y = right_hip_y - right_shoulder_y
        
        let left_knee_hip_angle_x = left_knee_x - left_hip_x
        let left_knee_hip_angle_y = left_knee_y - left_hip_y
        
        let left_hip_shoulder_angle_x = left_shoulder_x - left_hip_x
        let left_hip_shoulder_angle_y = left_shoulder_y - left_hip_y
        
        // Calculate Hip Hinge
        //let hip_hinge = (atan2(right_knee_hip_angle_x, right_knee_hip_angle_y) - atan2(right_hip_shoulder_angle_x, right_hip_shoulder_angle_y)) * 57.2958
        let hip_hinge = abs(Double((atan2(left_knee_hip_angle_x, left_knee_hip_angle_y) - atan2(left_hip_shoulder_angle_x, left_hip_shoulder_angle_y)) * 57.2958)).rounded()
        self.hingeAngles[BodyAngleContants.HIP_HINGE_ANGLE] = hip_hinge
    
        // Calculate knee hinge
        let left_ankle_knee_angle_x = left_ankle_x - left_knee_x
        let left_ankle_knee_angle_y = left_ankle_y - left_knee_y
        let knee_hinge = abs(Double((atan2(left_ankle_knee_angle_x, left_ankle_knee_angle_y) - atan2(left_knee_hip_angle_x, left_knee_hip_angle_y)) * 57.2958)).rounded()
        self.hingeAngles[BodyAngleContants.KNEE_HIP_ANGLE] = knee_hinge
        
        // Write the hip hinge into text
        drawTextInImage(hip_hinge: Double(hip_hinge), correctPosition: "", image: image)
        
        if (hip_hinge >= CorrectHipHingeConstants.CORRECT_HIP_L && hip_hinge <= CorrectHipHingeConstants.CORRECT_HIP_R) {
            drawSpecificLine(context: context, kp1_x: left_hip_x, kp1_y: left_hip_y, 
                             kp2_x: left_knee_x, kp2_y: left_knee_y, color: UIColor.green, lineWidth: 4.0)
            drawSpecificLine(context: context, kp1_x: left_hip_x, kp1_y: left_hip_y,
                             kp2_x: left_shoulder_x, kp2_y: left_shoulder_y, color: UIColor.green, lineWidth: 4.0)
            //textToSpeech(str: "Hip hinge/angle perfect, hold this position and bend your knees till you reach the kettlebell. Get up straight to finish.")
            drawTextInImage(hip_hinge: Double(hip_hinge), correctPosition: "Hip hinge angle in correct position please lower your hip and grab the kettle bell", image: image)
        }
        
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
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
    
    private func drawTextInImage(hip_hinge: Double, correctPosition: String, image: UIImage) {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica", size: 50)!
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ] as [NSAttributedString.Key : Any]
        let hip_text = "Hip Hinge Angle " + hip_hinge.description + "º"
        let rect = CGRect(origin: CGPoint.zero, size: image.size)
        let addTextRect = rect.offsetBy(dx: 0.0, dy: 50.0)
        
        hip_text.draw(in: rect, withAttributes: textFontAttributes)
        correctPosition.draw(in: addTextRect, withAttributes: textFontAttributes)
    }
    
    private func drawSpecificLine(context: CGContext, kp1_x: Float32, kp1_y: Float32, 
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


