//
//  PhotoDetailView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 21/05/24.
//

import SwiftUI
import AVKit

struct PhotoDetailView: View {
    let item: PhotoItem

    var body: some View {
        VStack {
            let player = AVPlayer(url: item.url)
            VideoPlayer(player: player)
                .onAppear{
                      if player.currentItem == nil {
                          let item = AVPlayerItem(url: item.url)
                            player.replaceCurrentItem(with: item)
                        }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            player.play()
                        })
                    }
        }
    }
}
