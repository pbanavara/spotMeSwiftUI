//
//  ContentView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            Text("Hello").tabItem { Label("Past workouts", systemImage: "photo") }
            Text("Setup workouts").tabItem { Label("Setup workouts", systemImage: "mic") }
            CamView().edgesIgnoringSafeArea(.all).tabItem {
                Label("Workout now", systemImage: "video")
            }
            
            
        }
    }
}

#Preview {
    ContentView()
}
