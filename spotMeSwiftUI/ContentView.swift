//
//  ContentView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "workoutNow"
    //let audioManager = AudioFeedbackManager.shared
    var body: some View {
        TabView (selection: $selectedTab) {
            CoachView().tabItem {
                Label("Workout now", systemImage: "figure.strengthtraining.functional")
            }.tag("workoutNow")
            PhotoGridView().environmentObject(PhotoDataModel()).tabItem { Label("Past workouts", systemImage: "photo.stack.fill") }.tag("history")
        }.onChange(of: selectedTab){ value in
            if (value == "workoutNow") {
                CameraManager.shared.configure()
            } else if (value == "history") {
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
