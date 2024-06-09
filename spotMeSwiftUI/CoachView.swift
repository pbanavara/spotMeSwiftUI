//
//  CoachView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 14/05/24.
//

import SwiftUI

struct CoachView: View {
    @State var selectedWorkout = KBWorkoutConstants.KB_DEAD_LIFT
    
    var body: some View {
        @ObservedObject var coachModel = CoachViewModel.shared
        NavigationStack {
            VStack {
                Section {
                    Picker("", selection: $selectedWorkout) {
                        ForEach(coachModel.Workouts, id: \.self) { workout in
                            Text(workout)
                        }
                    }.onChange(of: selectedWorkout) {
                        coachModel.selectedWorkout = selectedWorkout
                    }.pickerStyle(.inline)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 50.0, trailing: 0))
                    if let workoutDesc = coachModel.workoutSetupDict[selectedWorkout] {
                        Text(workoutDesc)
                    }
                    Spacer()
                }
                
                
            }
            NavigationLink("Start camera", destination: CamView()).padding(50)
                .navigationTitle("Choose your workout")
            
        }
    }
}

struct CoachView_Preview: PreviewProvider {
    static var previews: some View {
        CoachView()
    }
}
