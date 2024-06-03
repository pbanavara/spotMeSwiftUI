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
    @State var selectedWorkout = KBWorkoutConstants.KB_DEAD_LIFT
    var body: some View {
        @ObservedObject var coachModel = CoachViewModel.shared
        NavigationStack {
            //Text(agent.chatResponse).frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).padding()
            VStack {
                Picker("Please select a workout", selection: $selectedWorkout) {
                    ForEach(coachModel.workouts, id: \.self) { workout in
                        Text(workout)
                    }
                }.onChange(of: selectedWorkout) {
                    coachModel.selectedWorkout = selectedWorkout
                }
                if let descr = coachModel.workoutDescriptionDict[selectedWorkout] {
                    Text(descr).frame(alignment: .center).padding()
                }
                Image(.KB).resizable().scaledToFit()
                
            }
            NavigationLink("Start camera") {
                CamView()
            }.navigationTitle("Choose your Kettlebell Workout ").navigationBarTitleDisplayMode(.inline).padding()
            
        }
    }
}

struct CoachView_Preview: PreviewProvider {
    static var previews: some View {
        CoachView()
    }
}
