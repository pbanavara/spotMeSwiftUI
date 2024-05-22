//
//  Agent.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 14/05/24.
//

import Foundation

class Agent: ObservableObject {
    private let urlString = "http://192.168.29.172:8000/postPrompt"
    @Published var angle: Double?
    @Published var chatResponse = ""
    var numSamples = 0.0
    let samplesLimit = 200.0
    var prevHipAngle = 180.0
    let prevKneeAngle = 0.0
    let onnxPoseUtils: OnnxPoseUtils = OnnxPoseUtils.shared
    let audioManager = AudioFeedbackManager.shared
        
    init() {
        let startDict = ["prompt" : "hello", "user": "user1"]
        postSamples(angles: startDict)
    }
    
    func processVideoOutputText() {
        onnxPoseUtils.$hingeAngles.receive(on: DispatchQueue.main)
            .compactMap { angleDict in
                let hipAngle = angleDict[BodyAngleContants.HIP_HINGE_ANGLE]
                
                self.numSamples += 1
                if (self.numSamples == self.samplesLimit) {
                    self.numSamples = 0
                    
                    //if (hipAngle - self.prevHipAngle > 10) {
                        self.prevHipAngle = hipAngle!
                        self.numSamples = 0.0
                    let prompt = "Hip hinge angle is " + String(angleDict[BodyAngleContants.HIP_HINGE_ANGLE]!)
                                + "Knee hip angle is " + String(angleDict[BodyAngleContants.KNEE_HIP_ANGLE]!)
                        var promptDict = ["prompt": prompt]
                        promptDict["user"] = "user1"
                        self.postSamples(angles: promptDict)
                    //}
                }
                return angleDict["hipHingeAngle"]
            }.assign(to: &$angle)
    }
    
    func postSamples(angles: Dictionary<String, String>) {
        var request = URLRequest(url: URL(string: urlString)!)
        let jsonData = try? JSONSerialization.data(withJSONObject: angles, options: [.prettyPrinted])
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("\(String(describing: jsonData?.count))", forHTTPHeaderField: "Content-Length")
        request.httpBody = jsonData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data else {
                print("Upload error \(error.debugDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                        if let responseJSON = responseJSON as? [String: String] {
                            print(responseJSON) //Code after Successfull POST Request
                            self.audioManager.textToSpeech(str: responseJSON[BackendResponseConstants.BACKEND_JSON_RESPONSE]!)
                            self.chatResponse = responseJSON[BackendResponseConstants.BACKEND_JSON_RESPONSE]!.description
                        }
                } else {
                    self.chatResponse = "Backend server error"
                }
            }
            
        })
        task.resume()
        
    }
    
}
