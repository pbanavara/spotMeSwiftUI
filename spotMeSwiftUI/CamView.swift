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
        if let image = model.frame {
            if let keyPoints = model.keyPoints {
                GeometryReader { geometry in
                    Image(image, scale:1.0, orientation: .upMirrored,
                          label:Text("Camera feed"))
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height,
                        alignment: .center
                    )
                    .overlay(
                        Rectangle().path(in: CGRect(x: Double(keyPoints[0]),
                                                    y: Double(keyPoints[1]),
                                                    width: Double(keyPoints[2]),
                                                    height: Double(keyPoints[3])).insetBy(dx: geometry.size.width, dy: geometry.size.height)
                        ).stroke(.red, lineWidth: 2.0).scaledToFit())
                }
            }
            
        }
        else {
            Color.black
        }
        
    }
}

