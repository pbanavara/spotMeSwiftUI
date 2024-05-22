//
//  PhotoDetailView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 21/05/24.
//

import SwiftUI

struct PhotoDetailView: View {
    let item: PhotoItem

    var body: some View {
        AsyncImage(url: item.url) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        if let url = Bundle.main.url(forResource: "mushy1", withExtension: "jpg") {
            PhotoDetailView(item: PhotoItem(url: url))
        }
    }
}
