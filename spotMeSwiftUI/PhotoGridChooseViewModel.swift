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
        photoModel.filteredItems = photoModel.items.filter( {
            $0.workoutType == workoutType
        })
        
        print("Photo model items after filtering \(photoModel.items.count)")
    }
}
