//
//  GridViewItem.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 21/05/24.
//

import SwiftUI

struct GridItemView: View {
    let size: Double
    let item: PhotoItem
    
    var body: some View {
        ZStack (alignment: .topTrailing) {
            
            AsyncImage(url: item.url) { img in
                img.resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
        }
    }
}

struct GridItemView_Previews: PreviewProvider {
    static var previews: some View {
        if let url = Bundle.main.url(forResource: "IMG_8341", withExtension: "mov") {
            GridItemView(size: 50, item: PhotoItem(url: url))
        }
    }
}
