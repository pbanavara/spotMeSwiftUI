//
//  ContentView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "home"
    let audioManager = AudioFeedbackManager.shared
    var body: some View {
        TabView (selection: $selectedTab) {
            PhotoGridView().environmentObject(PhotoDataModel()).tabItem { Label("Past workouts", systemImage: "photo") }.tag("home")
            CamView().tabItem {
                Label("Workout now", systemImage: "video")
            }.tag("workoutNow")
        }.onChange(of: selectedTab){ value in
            if (value == "workoutNow") {
                CameraManager.shared.configure()
            } else if (value == "home") {
                CameraManager.shared.stopCamera()
            }
        }
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
