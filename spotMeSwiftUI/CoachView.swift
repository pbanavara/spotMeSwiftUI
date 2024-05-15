//
//  CoachView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 14/05/24.
//

import SwiftUI

struct CoachView: View {
    var body: some View {
        VStack {
            Image(systemName: "mic.fill").imageScale(.large).scaledToFill().animation(.bouncy, value: 0.5).padding()
            Text("Lets begin your Kettlebell Deadlift workout").frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            Button(action: {
               
            }) {
                Image(systemName: "record.circle").imageScale(.large)
            }
        }
    }
}

struct CoachView_Preview: PreviewProvider {
    static var previews: some View {
        CoachView()
    }
}
