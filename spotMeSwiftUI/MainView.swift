//
//  MainView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 31/05/24.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab = "workoutNow"
    var body: some View {
        TabView (selection: $selectedTab) {
            CoachView().tabItem {
                Label("Workout now", systemImage: "figure.strengthtraining.functional")
            }.tag("workoutNow")
            PhotoGridView().environmentObject(PhotoDataModel.shared).tabItem { Label("Past workouts", systemImage: "photo.stack.fill") }.tag("history")
        }.onChange(of: selectedTab){ value in
            if (value == "workoutNow") {
                CameraManager.shared.configure()
            } else if (value == "history") {
                CameraManager.shared.stopCamera()
            }
        }
    }
}

#Preview {
    MainView()
}
