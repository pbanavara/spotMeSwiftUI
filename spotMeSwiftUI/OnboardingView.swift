//
//  OnboardingView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 30/05/24.
//

import SwiftUI

struct OnboardingView: View {
    private var pronouns = ["He", "She", "Them/Their"]
    private var ageRanges = ["18-25", "25-35", "35-45", "45-55", "55+"]
    private var regions = ["North America", "South Asia", "Europe", "APAC"]
    @State private var selectedAgeRange = "18-25"
    @State private var selectedPronoun = "He"
    @State private var selectedRegion: String = "North America"
    @State private var userEmail: String = ""
    @State private var userPhone: Double?
    @State private var strength = false
    @State private var pushups = false
    @State private var run5k = false
    @State private var endurance = false
    
    private var countries = ["+1", "+91", "+44"]
    @State private var selectedCountry: String = ""
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Onboarding").foregroundStyle(.primary).multilineTextAlignment(.center).padding()
                Form {
                    Section {
                        TextField(
                            "Email",
                            text: $userEmail
                        )
                        TextField(
                            "Phone",
                            value: $userPhone,
                            format: .number
                        )
                    }
                    Section {
                        Picker("Your pronouns", selection: $selectedPronoun) {
                            ForEach(pronouns, id: \.self) { pronoun in
                                Text(pronoun)
                            }
                        }
                        Picker("Your age", selection: $selectedAgeRange) {
                            ForEach(ageRanges, id: \.self) { age in
                                Text(age)
                            }
                        }
                        Picker("Your location", selection: $selectedRegion) {
                            ForEach(regions, id: \.self) { region in
                                Text(region)
                            }
                        }
                    }
                    Section {
                        Text("Your goals").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        Toggle("Build Strength", isOn: $strength)
                        Toggle("Build Endurance", isOn: $endurance)
                    }
                    Section {
                        Text("Current fitness levels")
                        Toggle("Can do 10 pushups or 3 pullpus", isOn: $pushups)
                        Toggle("Can run 5k under 40 mins", isOn: $run5k)
                    }
                    
                }
                
            }
        }
        NavigationLink("Next", destination: StepFinal())
    }
}

struct StepFinal: View {
    @State var onboardingVM = OnboardingViewModel.shared
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    HStack {
                        Text("Starting Workout:")
                        Text("Kettlebell Swings")
                    }
                    HStack {
                        Text("Starting weight:")
                        Text("35 lbs")
                    }
                    HStack {
                        Text("Starting reps:")
                        Text("4-6")
                    }
                    HStack {
                        Text("Next progression:")
                        Text("In 3-4 weeks")
                    }
                    HStack {
                        Text("Next Weight")
                        Text("+20%")
                    }
                }
                List {
                    Text("Why Kettlebells ?")
                    Text("Because they are portable, simple and engage multiple muscle groups in any given workout. The best ROI in time. 15 to 20 minutes a day is more than enough to achieve your goals.").padding()
                }
                List {
                    Text("Form and efficiency")
                    Text("The form of every exercise directly drives results. The app will provide audio guidance for maintaining form throughout your workouts. The form is maintained in your recording as well. Serves as a visual progression log.").padding()
                }
                Spacer()
                
            }.navigationTitle("Summary and recommendation").navigationBarTitleDisplayMode(.inline)
            NavigationLink("Start workout", destination: MainView()).onTapGesture {
                onboardingVM.isComplete = true
            }
            
        }
    }
}

#Preview {
    OnboardingView()
}
