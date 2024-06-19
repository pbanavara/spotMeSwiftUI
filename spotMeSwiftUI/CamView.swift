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
                                        Image(systemName: "hand.thumbsup.fill").foregroundStyle(.green).frame(width: 200, height: 200).imageScale(.large)
                                        Rectangle()
                                            .fill(.clear)
                                            .frame(width: geometry.size.width, height: geometry.size.height)
                                            .border(Color.green, width: 6)
                                            .clipShape(RoundedRectangle(cornerRadius: 5.0))
                                        
                                    } else {
                                        Text("Body not in frame, Please align").foregroundStyle(.red).font(.largeTitle)
                                        Rectangle()
                                            .fill(.clear)
                                            .frame(width: geometry.size.width, height: geometry.size.height)
                                            .border(Color.red, width: 6)
                                            .clipShape(RoundedRectangle(cornerRadius: 5.0))
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
                                        Rectangle().cornerRadius(5.0).foregroundColor(.red).padding(.all, 15).overlay(Circle().stroke(lineWidth: 3.0).foregroundColor(.white))
                                    case false:
                                        Circle().foregroundColor(.red).padding(.all, 5).overlay(Circle().stroke(lineWidth: 3.0).foregroundColor(.white))
                                    }
                                }.frame(width: 60.0, height: 60.0).padding(.bottom, 50)
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
