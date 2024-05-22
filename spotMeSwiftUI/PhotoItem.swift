//
//  PhotoItem.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 21/05/24.
//

import SwiftUI

struct PhotoItem: Identifiable {
    let id = UUID()
    let url: URL
}

extension PhotoItem: Equatable {
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }
}
