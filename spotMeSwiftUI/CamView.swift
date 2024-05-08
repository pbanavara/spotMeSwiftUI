//
//  CamView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import SwiftUI

struct CamView: View {
    @StateObject var model = CamViewModel()
    let videoRecorder = FrameManager.shared
    @State var isPlaying = false
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
                
            }.overlay(alignment: .bottom) {
                Button(action: {
                    isPlaying.toggle()
                    if isPlaying {
                        videoRecorder.setActionState(state: false)
                    } else {
                        videoRecorder.setActionState(state: true)
                    }
                }) {
                    switch isPlaying {
                    case true:
                        //Text("Stop recording").background(Color.red)
                        //Image(systemName: "stop.circle").resizable().foregroundColor(.red)
                        Rectangle().cornerRadius(5.0).foregroundColor(.red).padding(.all, 20).overlay(Circle().stroke(lineWidth: 2.0).foregroundColor(.white))
                    case false:
                        Circle().foregroundColor(.red).padding(.all, 5).overlay(Circle().stroke(lineWidth: 2.0).foregroundColor(.white))
                    }
                }.frame(width: 50.0, height: 50.0).padding()
            }
            
        }
        else {
            Color.black
        }
        
        
    }
}

