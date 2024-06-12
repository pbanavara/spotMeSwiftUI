//
//  MainView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 31/05/24.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab = "home"
    @State private var mainModel = MainViewModel.shared
    init() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init(name: "Avenir-Heavy", size: 13)! ], for: .normal)
    }
    var body: some View {
        TabView (selection: $selectedTab) {
            OnboardingView().tabItem {
                Label("Home", systemImage: "house.circle.fill")
            }.tag("home")
            CoachView().tabItem {
                Label("Workout now", systemImage: "figure.strengthtraining.functional")
            }.tag("workoutNow")
            PhotoGridView().environmentObject(PhotoDataModel.shared).tabItem { Label("Past workouts", systemImage: "photo.stack.fill") }.tag("history")
        }.onChange(of: selectedTab){ value in
            if (value == "workoutNow") {
                //CameraManager.shared.configure()
            } else if (value == "history") {
                CameraManager.shared.stopCamera()
            } else if (value == "home") {
                CameraManager.shared.stopCamera()
            }
        }
    }
}

#Preview {
    MainView()
}
