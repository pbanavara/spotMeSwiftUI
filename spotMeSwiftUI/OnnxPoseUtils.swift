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

class OnnxPoseUtils : NSObject {
    /**
     ### This function accepts an UIImage and renders the detected pose points on the said image.
     *  It is key to use the correct model for the said purpose. Use the [Model generation] (https://onnxruntime.ai/docs/tutorials/mobile/pose-detection.html)
     *  It is also key to register the customOps function using the BridgingHeader
     */
    //var ortSession: ORTSession?
    private var synthesizer = AVSpeechSynthesizer()
    override init() {
        super.init()
    }
    
    func getPoseKeyPoints(inputData: Data, ortSession: ORTSession) -> [Float32]{
        print("Inside getPoseKeyPoints")
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
    
    func plotPose(inputData: Data, ortSession: ORTSession) -> UIImage{
        var image = UIImage()
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
            return try convertOutputTensorToImage(opTensor: outputTensor, inputImageData: inputData)
            
        } catch {
            print(error)
        }
        return image
    }
    
    /**
     Helper function to convert the output tensor into an image with the bounding box and keypoint data.
     */
    private func convertOutputTensorToImage(opTensor: ORTValue, inputImageData: Data) throws -> UIImage{
        
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
            return UIImage(data: inputImageData)!
        }
    }
    
    /**
     Helper function takes an input image and a boundding box CGRect along with the keypoints data to return a new image with the rect and keypoints drawn/
     TODO: // Optimize on generating a new image instead paint the data on the same image. iOS experts to chime in.
     
     */
    
    
    private func drawKeyPointsOnImage(image: UIImage, rectangle:CGRect, keypoints: [Float32]) -> UIImage {
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
        //context.move(to: CGPoint(x: Double(keypoints[0]), y: Double(keypoints[1])))
        /*
         for i in stride(from: 0, through: keypoints.count-1, by: 3) {
         let kp_x = keypoints[i]
         let kp_y = keypoints[i+1]
         let confidence = keypoints[i+2]
         if (confidence < 0.5) { // Can potentially remove hardcoding and make the confidence configurable
         continue
         }
         let rect = CGRect(x: Double(kp_x), y: Double(kp_y), width: 10.0, height: 10.0)
         UIRectFill(rect)
         
         }
         */
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
        drawSpecificLine(context: context, kp1_x: left_shoulder_x, kp1_y: left_shoulder_y, kp2_x: left_hip_x, kp2_y: left_hip_y, color: UIColor.white)
        //Draw specific line - left knee to left ankle
        let left_knee_x = keypoints[39]
        let left_knee_y = keypoints[40]
        drawSpecificLine(context: context, kp1_x: left_hip_x, kp1_y: left_hip_y, kp2_x: left_knee_x, kp2_y: left_knee_y, color: UIColor.white)
        let left_ankle_x = keypoints[45]
        let left_ankle_y = keypoints[46]
        drawSpecificLine(context: context, kp1_x: left_knee_x, kp1_y: left_knee_y, kp2_x: left_ankle_x, kp2_y: left_ankle_y, color: UIColor.white)
        
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
        let hip_hinge = (atan2(left_knee_hip_angle_x, left_knee_hip_angle_y) - atan2(left_hip_shoulder_angle_x, left_hip_shoulder_angle_y)) * 57.2958
        NSLog("Hip Hinge \(hip_hinge)")
        
        // Write the hip hinge into text
        drawTextInImage(hip_hinge: Double(hip_hinge), image: image)
        
        if (hip_hinge >= 60.0 && hip_hinge <= 90.0) {
            drawSpecificLine(context: context, kp1_x: right_hip_x, kp1_y: right_hip_y, kp2_x: right_knee_x, kp2_y: right_knee_y, color: UIColor.green)
            //textToSpeech(str: "Hip hinge/angle perfect, hold this position and bend your knees till you reach the kettlebell. Get up straight to finish.")
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
    
    private func drawTextInImage(hip_hinge: Double, image: UIImage) {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Arial", size: 52)!
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ] as [NSAttributedString.Key : Any]
        let text = "Hip Hinge ::" + hip_hinge.description
        let rect = CGRect(origin: CGPoint.zero, size: image.size)
        
        text.draw(in: rect, withAttributes: textFontAttributes)
    }
    
    private func drawSpecificLine(context: CGContext, kp1_x: Float32, kp1_y: Float32, kp2_x: Float32, kp2_y: Float32, color: UIColor) {
        context.setLineWidth(3.0)
        context.setStrokeColor(color.cgColor)
        context.move(to: CGPoint(x: Double(kp1_x), y: Double(kp1_y)))
        context.addLine(to: CGPoint(x: Double(kp2_x), y: Double(kp2_y)))
        context.strokePath()
    }
    
    var player: AVAudioPlayer?
    
    func textToSpeech(str: String) {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [])
        synthesizer.delegate = self
        let utterance = AVSpeechUtterance(string: str)
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.3
        let voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.voice = voice
        synthesizer.speak(utterance)
        utterance.postUtteranceDelay = 1.0
        //synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
}

extension OnnxPoseUtils: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.red, range: characterRange)
        NSLog("Text is spoken")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        NSLog("Finished speaking")
        synthesizer.stopSpeaking(at: AVSpeechBoundary.word)
    }
}

