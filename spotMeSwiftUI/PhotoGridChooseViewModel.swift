//
//  PhotoGridChooseViewModel.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 29/05/24.
//

import Foundation

class PhotoGridChooseViewModel {
    let photoModel:PhotoDataModel = PhotoDataModel.shared
    
    func filterVideos(workoutType: String) {
        print("Photo model items before filtering \(photoModel.items.count)")
        //TODO filter based on chosen workouttypes
        
        print("Photo model items after filtering \(photoModel.items.count)")
    }
}
