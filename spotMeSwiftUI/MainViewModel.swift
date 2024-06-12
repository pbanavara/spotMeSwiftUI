//
//  MainViewModel.swift
//  CallindraFitness
//
//  Created by Pradeep Banavara on 12/06/24.
//

import Foundation

class MainViewModel:NSObject {
    static let shared = MainViewModel()
    private var poseModel: PoseModel?
    
    private override init() {
        super.init()
        DispatchQueue.global(qos: .background).async {
            self.poseModel = PoseModel.shared
        }
    }
}
