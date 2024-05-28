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
    static let KB_HALO = "Kettlebell Halo"
    static let GEN_WORKOUT = "Regular workout"
}


class CoachViewModel: NSObject, ObservableObject {
    
    var workoutDescriptionDict: Dictionary<String, String> = [:]
    
    let workouts = [KBWorkoutConstants.KB_DEAD_LIFT, KBWorkoutConstants.KB_SQUAT, KBWorkoutConstants.KB_SWING, KBWorkoutConstants.KB_HALO, KBWorkoutConstants.GEN_WORKOUT]
    var workoutDescr: String = ""
    static let shared = CoachViewModel()
    @Published var selectedWorkout: String = ""
    
    private override init() {
        workoutDescriptionDict[KBWorkoutConstants.GEN_WORKOUT] = "General workout, you can record the video containing all the pose angles superimposed"
        workoutDescriptionDict[KBWorkoutConstants.KB_DEAD_LIFT] = "Starting position reference image. Note the hip and knee angles. Stand left facing to the camera. When ready click start camera"
        workoutDescriptionDict[KBWorkoutConstants.KB_SQUAT] = "Starting position. Note the hip and knee angles. Stand left facing to the camera. When ready click start camera"
    }
    
}
