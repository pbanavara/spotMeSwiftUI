//
//  TestView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 15/05/24.
//

import SwiftUI

struct TestView: View {
    @State var isPlaying = false
    @State var isVisualizing = false
    var body: some View {
        VStack {
            GeometryReader { geometry in
                AsyncImage(url: URL(string: "https://picsum.photos/id/12/200")).scaledToFit()
                
            }.overlay(alignment: .bottom) {
                Button(action: {
                    isPlaying.toggle()
                    if isPlaying {
                        //videoRecorder.setActionState(state: false)
                    } else {
                        //videoRecorder.setActionState(state: true)
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
                        .frame(width: 3, height: .random(in: isVisualizing ? 8...20 : 4...30))
                        .animation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true), value: isVisualizing)
                        .onAppear {
                            isVisualizing.toggle()
                        }
                }
            }
        }
    }
}

#Preview {
    TestView()
}
