//
//  CamView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import SwiftUI

struct CamView: View {
    @StateObject var model = CamViewModel()
    
    let videoRecorder = VideoRecordManager()
    @StateObject var agent = Agent()
    var body: some View {
        var isVisualizing = false
        @State var isPlaying = false
        if let image = model.poseImage {
            VStack {
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
                            Rectangle().cornerRadius(5.0).foregroundColor(.red).padding(.all, 15).overlay(Circle().stroke(lineWidth: 2.0).foregroundColor(.white))
                        case false:
                            Circle().foregroundColor(.red).padding(.all, 5).overlay(Circle().stroke(lineWidth: 2.0).foregroundColor(.white))
                        }
                    }.frame(width: 50.0, height: 50.0).padding(.bottom, 30)
                }
                HStack(spacing: 1.0) {
                    ForEach(0 ..< 20) { item in
                        RoundedRectangle(cornerRadius: 2.0)
                            .frame(width: 5, height: .random(in: isVisualizing ? 10...50 : 4...30))
                            .animation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true), value: isVisualizing)
                    }
                }
            }
            
            
        }
    
        else {
            VStack {
                Text(agent.chatResponse).frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).padding()
                Button(action: {
                    model.getPoseImage()
                    agent.processVideoOutputText()
                    agent.$chatResponse.receive(on: RunLoop.current)
                        .compactMap ({ value in
                            print(value)
                            if (value.isEmpty) {
                                isVisualizing = false
                            } else {
                                isVisualizing = true
                            }
                        })
                }) {
                    Image(systemName: "record.circle").imageScale(.large)
                }
            }
        }
    }
}

struct CamView_Previews: PreviewProvider {
    static var previews: some View {
        CamView()
    }
}
