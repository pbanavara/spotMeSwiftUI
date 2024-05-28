//
//  AudioViewModel.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 24/05/24.
//

import Foundation

class AudioViewModel: ObservableObject {
    @Published var text: String?
    private var agent = Agent.shared
    var audioManager = AudioFeedbackManager.shared
    
    init() {
        agent.$chatResponse
            .receive(on: RunLoop.current)
            .compactMap { value in
                self.audioManager.textToSpeech(str: value.lowercased())
                return value
            }.assign(to: &$text)
    }
    
}
