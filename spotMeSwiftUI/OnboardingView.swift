//
//  OnboardingView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 30/05/24.
//

import SwiftUI

struct OnboardingView: View {
    @State var paths  = [Int]()
    var body: some View {
        NavigationStack {
            Text("Are you new to Kettlebell workouts?").padding()
            VStack {
                
            }
            HStack {
                NavigationLink("Yes", destination: StepDemographics()).padding()
                NavigationLink("No", destination: StepDemographics())
            }
        }
    }
}

struct StepDemographics: View {
    private var pronouns = ["He", "She", "Them/Their"]
    private var ageRanges = ["18-25", "25-35", "35-45", "45-55", "55+"]
    private var regions = ["North America", "South Asia", "Europe", "APAC"]
    @State private var selectedAgeRange = "18-25"
    @State private var selectedPronoun = "He"
    @State private var selectedRegion: String = "North America"
    var body: some View {
        NavigationStack {
            VStack {
                Text("We will collect basic demographics information to personalize your workouts").foregroundStyle(.primary).multilineTextAlignment(.center).padding()
                Spacer()
                Text("Your Pronoun")
                Picker("Please select", selection: $selectedPronoun) {
                    ForEach(pronouns, id: \.self) { pronoun in
                        Text(pronoun)
                    }
                }
                .onChange(of: selectedPronoun) {
                    Text(selectedPronoun)
                }
                Text("Your Age")
                Picker("Please select", selection: $selectedAgeRange) {
                    ForEach(ageRanges, id: \.self) { age in
                        Text(age)
                    }
                }
                .onChange(of: selectedAgeRange) {
                    Text(selectedAgeRange)
                }
                Text("Your location")
                Picker("Please select", selection: $selectedRegion) {
                    ForEach(regions, id: \.self) { region in
                        Text(region)
                    }
                }.onChange(of: selectedRegion) {
                    Text(selectedRegion)
                }
                Spacer()
            }
        }
        NavigationLink("Next", destination: StepGoal()).padding()
        
        
    }
}

struct StepGoal: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("What is your goal?").padding()
            }
            VStack {
                NavigationLink("Build strength", destination: StepCurrStrength()).padding()
                NavigationLink("Improve endurance", destination: StepCurrEndurance()).padding()
                NavigationLink("Both", destination: StepCurrBoth()).padding()
                
            }
        }
    }
}

struct StepCurrBoth: View {
    var body: some View {
        NavigationStack {
            Text("What are your current strength and endurance levels?").padding()
            VStack {
                
            }
            VStack {
                NavigationLink("Run a 5K under 40 mins", destination: StepGoal()).padding()
                NavigationLink("Can walk for an hour", destination: CoachView())
            }
        }
    }
}

struct StepCurrEndurance: View {
    var body: some View {
        NavigationStack {
            Text("What is your current fitness level?").padding()
            VStack {
                
            }
            VStack {
                NavigationLink("Can run a 5K under 40 mins", destination: StepGoal()).padding()
                NavigationLink("Can walk for an hour", destination: CoachView())
            }
        }
    }
}

struct StepCurrStrength: View {
    var body: some View {
        NavigationStack {
            Text("What is your current fitness level?").padding()
            VStack {
                
            }
            VStack {
                NavigationLink("Can do 3 pullups or 20 pushups", destination: StepFinalAdv()).padding()
                NavigationLink("I am new to all this", destination: StepFinalBegineer())
            }
            
        }
    }
}

struct StepFinalBegineer: View {
    var body: some View {
        VStack {
            Text("Thank you for providing all the details. Based on data you provided, we are recommending the following").padding()
            HStack {
                Label("Weight:", image: .KB_ICON)
                Text("20 to 25 lbs")
            }.frame(width: 250, alignment: .leading).padding()
            HStack {
                Label("Workout:", image: .KB_ICON)
                Text("Deadlift")
            }.frame(width: 250, alignment: .leading).padding()
            HStack {
                Label("3 sets", systemImage: "repeat")
                Text("10-12 reps each set")
            }.frame(width: 250, alignment: .leading).padding()
            HStack {
                Label("15 mins", systemImage: "clock")
            }.frame(width: 250, alignment: .leading).padding()
            
            Text("Consistency is the key, perform workouts every day.").padding()
        }
        Spacer()
        Button {
            
        } label: {
            Text("Done")
        }
    }
}

struct StepFinalAdv: View {
    @ObservedObject var onboardingModel = OnboardingViewModel.shared
    var body: some View {
        if onboardingModel.isComplete {
            MainView()
        } else {
            Text("Your best bet is to start with a medium kettlebell 40 - 60 lbs.\nPerform any Kettlebell workout.\nAim for a 30 minute workout every day").padding()
            Text("Your onboarding is now complete")
            Button(action: {
                onboardingModel.isComplete = true
            }, label: {
                Text("Done")
            })
        }
        
        
    }
}



#Preview {
    OnboardingView()
}
