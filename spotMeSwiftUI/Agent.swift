//
//  Agent.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 14/05/24.
//

import Foundation

class Agent: ObservableObject {
    private let urlString = "http://192.168.29.172:8000/postPrompt"
    @Published var angle: String?
    @Published var chatResponse = ""
    var numSamples = 0.0
    let samplesLimit = 150.0
    
    let onnxPoseUtils: OnnxPoseUtils = OnnxPoseUtils.shared
    
    init() {
        let startDict = ["prompt" : "hello"]
        postSamples(angles: startDict)
    }
    
    func processVideoOutputText() {
        onnxPoseUtils.$hingeAngles.receive(on: RunLoop.main)
            .compactMap { angleDict in
                self.numSamples += 1.0
                if (self.numSamples == self.samplesLimit) {
                    self.numSamples = 0.0
                    let prompt = (angleDict["hipHingeAngle"] ?? "") + " " + (angleDict["kneeHipAngle"] ?? "")
                    let promptDict = ["prompt": prompt]
                    self.postSamples(angles: promptDict)
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
            guard let data = data else { return }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: String] {
                    print(responseJSON) //Code after Successfull POST Request
                    self.chatResponse = responseJSON["response"]!.description
                }
        })
        task.resume()
        
    }
    
}
