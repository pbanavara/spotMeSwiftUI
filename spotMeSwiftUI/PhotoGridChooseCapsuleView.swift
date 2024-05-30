//
//  PhotoGridChooseCapsuleView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 27/05/24.
//

import SwiftUI

struct PhotoGridChooseCapsuleView: View {
    let gridChooseModel = PhotoGridChooseViewModel()
    
    var CapsuleView: some View {
        Capsule().fill(Color.gray).frame(width: 100, height: 30).padding([.bottom], 50).padding([.leading], 5)
    }
    @State private var offSetAmount = CGSize.zero
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Capsule().fill(Color.gray.opacity(0.6)).frame(width: geometry.size.width, height: 40).padding([.bottom], 50)
                HStack {
                    CapsuleView.offset(offSetAmount)
                    Spacer()
                }
                HStack {
                    Text("KB Deadlift").frame(width: 100, height: 30)
                        .padding([.bottom], 50)
                        .padding([.leading], 0)
                        .gesture(
                        TapGesture()
                            .onEnded { value in
                                gridChooseModel.filterVideos(workoutType: KBWorkoutConstants.KB_DEAD_LIFT)
                                withAnimation(.linear(duration: 0.5)) {
                                    offSetAmount = CGSizeMake(0.0, 0.0)
                                }
                            }
                    )
                    Spacer()
                    Text("KB Swing")
                        .frame(width: 80, height: 30)
                        .padding([.bottom], 50)
                        .padding([.leading], 0)
                        .gesture(
                        TapGesture()
                            .onEnded { _ in
                                gridChooseModel.filterVideos(workoutType: KBWorkoutConstants.KB_SWING)
                                withAnimation(.linear(duration: 0.5)) {
                                    offSetAmount = CGSizeMake(geometry.size.width*0.38, 0.0)
                                }
                                
                            }
                    )
                    Spacer()
                    Text("All Videos")
                        .frame(width: 80, height: 30)
                        .padding([.bottom], 50)
                        .padding([.trailing], 10)
                        .gesture(
                        TapGesture()
                            .onEnded { _ in
                                gridChooseModel.filterVideos(workoutType: "")
                                withAnimation(.linear(duration: 0.5)) {
                                    offSetAmount = CGSizeMake(geometry.size.width*0.73, 0.0)
                                }
                            }
                    )
                }
            }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
        }.frame(alignment: .bottom)
    }
}

#Preview {
    PhotoGridChooseCapsuleView()
}
