//
//  PhotoItem.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 21/05/24.
//

import SwiftUI

struct PhotoItem: Identifiable {
    let id = UUID()
    var url: URL?
    var workoutType: String
    var createdAt: Date?
    //let annotationTextPath: String?
    
    init() {
        workoutType = KBWorkoutConstants.KB_SWING
        url = nil
    }
}

extension PhotoItem: Equatable {
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }
}
