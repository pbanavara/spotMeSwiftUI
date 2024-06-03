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
    @Published var shouldRecord = false
    var numSamples = 0.0
    let samplesLimit = 50.0
    let onnxPoseUtils: OnnxPoseUtils = OnnxPoseUtils.sharedOnnx
    var prevChatResponse = ""
    var currentChatResponse = ""
    //let audioManager = AudioFeedbackManager.shared
    
    static let shared = Agent()
    
    private init() {
        
    }
    
    func processVideoOutputText() {
        onnxPoseUtils.$hingeAngles.receive(on: DispatchQueue.main)
            .compactMap { angleDict in
                self.numSamples += 1
                if (self.numSamples == self.samplesLimit) {
                    self.numSamples = 0.0
                    let prompt = "Hip hinge angle is " + String(angleDict[BodyAngleContants.HIP_HINGE_ANGLE]!)
                    + "Knee hip angle is " + String(angleDict[BodyAngleContants.KNEE_HIP_ANGLE]!)
                    var promptDict = [BodyAngleContants.HIP_HINGE_ANGLE: prompt]
                    promptDict["user"] = "user1"
                    //self.postSamples(angles: promptDict)
                    self.calculateCorrectPosition(promptDict: angleDict)
                }
                return angleDict["hipHingeAngle"]
            }.assign(to: &$angle)
    }
    
    func calculateCorrectPosition(promptDict: Dictionary<String, Double>) {
        if let hipHingeAngle = promptDict[BodyAngleContants.HIP_HINGE_ANGLE] {
            if (hipHingeAngle > CorrectHipHingeConstants.CORRECT_HIP_L && hipHingeAngle <= CorrectHipHingeConstants.CORRECT_HIP_R) {
                    currentChatResponse = "Perfect hip hinge. Lower your body until you can reach the kettle bell, grab the kettle bell and move back up. Squeeze your glutes and maintain hip hinge"
                    if prevChatResponse != currentChatResponse {
                        prevChatResponse = currentChatResponse
                        self.chatResponse = currentChatResponse
                        return
                    }
            } else if (hipHingeAngle > CorrectHipHingeConstants.CORRECT_HIP_R) {
                    currentChatResponse = "You need more lean, keep bending your knees and lean forward, while keeping the back straight "
                    if prevChatResponse != currentChatResponse {
                        prevChatResponse = currentChatResponse
                        self.chatResponse = currentChatResponse
                        return
                    }
                    
            } else if (hipHingeAngle < CorrectHipHingeConstants.CORRECT_HIP_L) {
                    currentChatResponse = "You have excessive forward lean, please lean backwards a bit"
                    if prevChatResponse != currentChatResponse {
                        prevChatResponse = currentChatResponse
                        self.chatResponse = currentChatResponse
                        return
                    }
                    
                }
        }
        self.chatResponse = ""
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
                        //self.audioManager.textToSpeech(str: responseJSON[BackendResponseConstants.BACKEND_JSON_RESPONSE]!)
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
