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
    @StateObject var agent = Agent.shared
    @State var isPlaying = false
    @State var animationHeight:Double?
    
    init() {
        CameraManager.shared.configure()
    }
    var body: some View {
        NavigationStack {
            if let image = model.poseImage {
                ZStack {
                    GeometryReader { geometry in
                        Image(image, scale:1.0, orientation: .up, label:Text(""))
                            .resizable()
                            .scaledToFill()
                            .overlay(alignment: .top) {
                                if let position = model.bodyInPosition {
                                    if position == true {
                                        Text("Body in frame")
                                        Rectangle()
                                            .fill(.clear)
                                            .frame(width: geometry.size.width, height: geometry.size.height)
                                            .border(Color.green, width: 2)
                                            .clipShape(RoundedRectangle(cornerRadius: 5.0))
                                        
                                    } else {
                                        Text("Body not in frame, Please align")
                                        Rectangle()
                                            .fill(.clear)
                                            .frame(width: geometry.size.width, height: geometry.size.height)
                                            .border(Color.red, width: 4)
                                            .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                    }
                                }
                                
                            }
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
                                }.frame(width: 50.0, height: 50.0).padding(.bottom, 100)
                            }
                        
                    }
                }.onAppear() {
                    UIApplication.shared.isIdleTimerDisabled = true
                }.onDisappear() {
                    UIApplication.shared.isIdleTimerDisabled = false
                }.navigationTitle(CoachViewModel.shared.selectedWorkout).navigationBarTitleDisplayMode(.inline)
                
                
            }
            
            else {
                Text("Model loading...")
                ProgressView()
            }
        }.onAppear() {
            CameraManager.shared.configure()
        }
        .onDisappear() {
            CameraManager.shared.stopCamera()
        }
    }
}

struct CamView_Previews: PreviewProvider {
    static var previews: some View {
        CamView()
    }
}
