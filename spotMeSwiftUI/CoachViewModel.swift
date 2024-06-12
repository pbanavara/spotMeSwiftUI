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
    static let BAR_DEAD_LIFT = "Barbell Deadlift"
    static let BAR_SQUAT = "Barbell Squat"
    static let BAR_BENCH_PRESS = "Barbell Bench press"
    static let BAR_SHOULDER_PRESS = "Barbell Shoulder press"
    static let BODYWEIGHT_PUSHUP = "Bodyweight Pushup"
    static let BODYWEIGHT_PULLUP = "Bodyweight Pullup"
    static let BODYWEIGHT_CRUNCH = "Ab crunch"
    static let SPORTS_TENNIS = "Tennis"
}


class CoachViewModel: NSObject, ObservableObject {
    var workoutSetupDict: Dictionary<String, String> = Dictionary()
    let alignString = "Align yourself until you see a green rectangle in the camera view.\n"
    let instruction = "Mount the phone on a tipod/magnetic holder.\nPosition yourself so that the left side of your body faces the camera.\nEnsure that your full body is in the frame.\n\nWhen ready click start camera.\nAdjust your position in the camera view before recording."
    let workouts = [KBWorkoutConstants.KB_SWING,
                    KBWorkoutConstants.KB_DEAD_LIFT,
                    KBWorkoutConstants.KB_SHOULDER,
                    KBWorkoutConstants.BAR_DEAD_LIFT,
                    KBWorkoutConstants.BAR_SQUAT,
                    KBWorkoutConstants.BAR_BENCH_PRESS,
                    KBWorkoutConstants.BODYWEIGHT_PUSHUP]
    let kbWorkouts = [KBWorkoutConstants.KB_DEAD_LIFT, KBWorkoutConstants.KB_SQUAT, KBWorkoutConstants.KB_SWING]
    let barbellWorkouts = [KBWorkoutConstants.BAR_SQUAT, KBWorkoutConstants.BAR_DEAD_LIFT, KBWorkoutConstants.BAR_BENCH_PRESS, 
                           KBWorkoutConstants.BAR_SHOULDER_PRESS,
                           KBWorkoutConstants.KB_SQUAT, KBWorkoutConstants.KB_DEAD_LIFT, KBWorkoutConstants.KB_SWING,
                           KBWorkoutConstants.BODYWEIGHT_CRUNCH, KBWorkoutConstants.BODYWEIGHT_PUSHUP, KBWorkoutConstants.BODYWEIGHT_PULLUP]
    
    var workoutDescr: String = ""
    static let shared = CoachViewModel()
    @Published var selectedWorkout: String = KBWorkoutConstants.KB_DEAD_LIFT
    
    private override init() {
        let kbDlDesString =  alignString + "Focus on the hip hinge while lifting the Kettlebell"
        workoutSetupDict[KBWorkoutConstants.KB_DEAD_LIFT] = kbDlDesString
        workoutSetupDict[KBWorkoutConstants.BAR_SQUAT] = alignString + "Focus on the correct back angle."
        workoutSetupDict[KBWorkoutConstants.BAR_DEAD_LIFT] = alignString + "Focus on hip angle."
        workoutSetupDict[KBWorkoutConstants.KB_SWING] =  alignString + "Focus on hip hinge correctness."
        workoutSetupDict[KBWorkoutConstants.BAR_SQUAT] = alignString + "Focus on hip hinge and back angle."
        workoutSetupDict[KBWorkoutConstants.BODYWEIGHT_PUSHUP] = alignString + "Focus on the elbow angle."
        workoutSetupDict[KBWorkoutConstants.BODYWEIGHT_PUSHUP] = alignString + "Focus on the elbow angle."
        
    }
    
}
