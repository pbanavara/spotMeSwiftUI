//
//  ContentView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "home"
    var body: some View {
        TabView (selection: $selectedTab) {
            Text("Hello").tabItem { Label("Past workouts", systemImage: "photo") }.tag("home")
            Text("Setup workouts")
                .tabItem { Label("Setup workouts", systemImage: "mic") }.tag("setupWorkouts")
            CamView().edgesIgnoringSafeArea(.all).tabItem {
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

#Preview {
    ContentView()
}
