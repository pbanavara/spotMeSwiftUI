//
//  ContentView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "workoutNow"
    @ObservedObject var onboardingModel = OnboardingViewModel.shared
    //let audioManager = AudioFeedbackManager.shared
    var body: some View {
        MainView()
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
