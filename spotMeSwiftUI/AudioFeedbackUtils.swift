//
//  AudioFeedbackUtils.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 13/05/24.
//

import Foundation
import AVFoundation
import Combine
import UIKit

class AudioFeedbackManager:NSObject {
    
    private var synthesizer = AVSpeechSynthesizer()
    var player: AVAudioPlayer?
    
    func textToSpeech(str: String) {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [])
        synthesizer.delegate = self
        let utterance = AVSpeechUtterance(string: str)
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.4
        utterance.volume = 0.3
        let voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.voice = voice
        synthesizer.speak(utterance)
        utterance.postUtteranceDelay = 1.0
    }
}

extension AudioFeedbackManager: AVSpeechSynthesizerDelegate {
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

