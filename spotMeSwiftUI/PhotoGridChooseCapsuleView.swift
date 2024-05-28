//
//  PhotoGridChooseCapsuleView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 27/05/24.
//

import SwiftUI

struct PhotoGridChooseCapsuleView: View {
    
    var CapsuleView: some View {
        Capsule().fill(Color.gray).frame(width: 100, height: 30).padding([.bottom], 60).padding([.leading], 5)
    }
    @State private var offSetAmount = CGSize.zero
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Capsule().fill(Color.gray.opacity(0.6)).frame(width: geometry.size.width, height: 40).padding([.bottom], 60)
                HStack {
                    CapsuleView.offset(offSetAmount)
                    Spacer()
                }
                HStack {
                    Text("KB").frame(width: 80, height: 30)
                        .padding([.bottom], 60)
                        .padding([.leading], 10)
                        .gesture(
                        TapGesture()
                            .onEnded { _ in
                                withAnimation(.linear(duration: 0.5)) {
                                    offSetAmount = CGSizeMake(0.0, 0.0)
                                }
                            }
                    )
                    Spacer()
                    Text("General")
                        .frame(width: 80, height: 30)
                        .padding([.bottom], 60)
                        .padding([.leading], 10)
                        .gesture(
                        TapGesture()
                            .onEnded { _ in
                                withAnimation(.linear(duration: 0.5)) {
                                    offSetAmount = CGSizeMake(geometry.size.width*0.35, 0.0)
                                }
                                
                            }
                    )
                    Spacer()
                    Text("All Videos")
                        .frame(width: 80, height: 30)
                        .padding([.bottom], 60)
                        .padding([.trailing], 30)
                        .gesture(
                        TapGesture()
                            .onEnded { _ in
                                withAnimation(.linear(duration: 0.5)) {
                                    offSetAmount = CGSizeMake(geometry.size.width*0.7, 0.0)
                                }
                            }
                    )
                }
            }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
        }
    }
}

#Preview {
    PhotoGridChooseCapsuleView()
}
