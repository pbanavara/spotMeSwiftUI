//
//  CoachView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 14/05/24.
//

import SwiftUI

struct CoachView: View {
    //@StateObject var agent = Agent()
    //@StateObject var model = CamViewModel()
    var workouts = ["Kettlebell deadlift", "Kettlebell Swing", "Barbell deadlift", "Barbell Squat"]
    var workoutDescr = "Starting position reference image. Note the hip and knee angles. Stand left facing to the camera. When ready click start camera"
    @State private var selectedWorkout = "Kettlebell deadlift"
    var body: some View {
        
        NavigationStack {
            //Text(agent.chatResponse).frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).padding()
            VStack {
                Picker("Please select a workout", selection: $selectedWorkout) {
                    ForEach(workouts, id: \.self) {
                        Text($0)
                    }
                }
                Text(workoutDescr).frame(alignment: .center).padding()
                Image(.KB).resizable().scaledToFit()
            }
            NavigationLink("Start camera") {
                CamView()
            }.navigationTitle("Workout").navigationBarTitleDisplayMode(.inline).padding()
            
        }
    }
}

struct CoachView_Preview: PreviewProvider {
    static var previews: some View {
        CoachView()
    }
}
