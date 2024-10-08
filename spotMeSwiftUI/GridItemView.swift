//
//  GridViewItem.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 21/05/24.
//

import SwiftUI
import AVFoundation

struct GridItemView: View {
    let size: Double
    let item: PhotoItem
    
    func videoPreviewImage(url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        if let cgImage = try? generator.copyCGImage(at: CMTime(seconds: 2, preferredTimescale: 60), actualTime: nil) {
            return UIImage(cgImage: cgImage)
        }
        else {
            return nil
        }
    }
    
    var body: some View {
        ZStack (alignment: .topTrailing) {
            if let url = item.url {
                if let image = videoPreviewImage(url: url) {
                    Image(uiImage: image).resizable().scaledToFill().frame(width:size, height: size)
                }
            }
        }
    }
}
