//
//  CamView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import SwiftUI

struct CamView: View {
    @StateObject var model = CamViewModel()
    var body: some View {
        if let image = model.poseImage {
                GeometryReader { geometry in
                    Image(image, scale:1.0, orientation: .up, label:Text(""))
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height,
                        alignment: .center
                    )
                }
        }
        else {
            Color.black
        }
        
    }
}

