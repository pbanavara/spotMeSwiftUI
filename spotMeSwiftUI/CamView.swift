//
//  CamView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 25/04/24.
//

import SwiftUI
import Combine

struct CamView: View {
    @StateObject var model = CamViewModel()
    let videoRecorder = VideoRecordManager()
    //@StateObject var audioManager = AudioFeedbackManager.shared
    @StateObject var agent = Agent.shared
    @State var isPlaying = false
    @State var animationHeight:Double?
    var body: some View {
        if let image = model.poseImage {
            ZStack {
                Image(image, scale:1.0, orientation: .upMirrored, label:Text(""))
                    .resizable()
                    .scaledToFit()
                    .overlay(alignment: .bottom) {
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
                AudioView().background(.gray)
            }
            
            
        }
        
        else {
            /*
             VStack {
             Text(agent.chatResponse).frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).padding()
             Button(action: {
             model.getPoseImage()
             agent.processVideoOutputText()
             
             }) {
             Image(systemName: "record.circle").imageScale(.large)
             }
             }
             */
            Text("Model loading please wait")
            ProgressView()
        }
    }
}

struct CamView_Previews: PreviewProvider {
    static var previews: some View {
        CamView()
    }
}
