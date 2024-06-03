//
//  OnboardingViewModel.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 31/05/24.
//

import Foundation

class OnboardingViewModel: ObservableObject {
    @Published var isComplete = true
    static let shared = OnboardingViewModel()
    
    private init() {
        
    }
}
