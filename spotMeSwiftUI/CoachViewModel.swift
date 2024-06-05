//
//  CoachViewModel.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 26/05/24.
//

import Foundation

enum KBWorkoutConstants {
    static let KB_DEAD_LIFT = "Kettlebell Deadlift"
    static let KB_SWING = "Kettlebell Swing"
    static let KB_SQUAT = "Kettlebell Squat"
    static let KB_SHOULDER = "Kettlebell Shoulder Press"
    static let GEN_WORKOUT = "General workout"
}


class CoachViewModel: NSObject, ObservableObject {
    
    var workoutDescriptionDict: Dictionary<String, String> = [:]
    
    let workouts = [KBWorkoutConstants.KB_DEAD_LIFT, KBWorkoutConstants.KB_SQUAT, KBWorkoutConstants.KB_SWING, KBWorkoutConstants.GEN_WORKOUT]
    var workoutDescr: String = ""
    static let shared = CoachViewModel()
    @Published var selectedWorkout: String = KBWorkoutConstants.KB_DEAD_LIFT
    
    private override init() {
        workoutDescriptionDict[KBWorkoutConstants.GEN_WORKOUT] = "General workout.\nStand left facing to the camera.\nWhen ready click start camera"
        workoutDescriptionDict[KBWorkoutConstants.KB_DEAD_LIFT] = "Starting position reference image.\nNote the hip and knee angles.\nStand left facing to the camera.\nWhen ready click start camera"
        workoutDescriptionDict[KBWorkoutConstants.KB_SQUAT] = "Starting position.\nNote the hip and knee angles.\nStand left facing to the camera.\nWhen ready click start camera"
    }
    
}
