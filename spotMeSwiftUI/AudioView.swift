//
//  AudioView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 24/05/24.
//

import SwiftUI
import Combine

struct AudioView: View {
    @StateObject var model = AudioViewModel()
    
    
    var body: some View {
        if let text = model.text {
            Text(text)
        }
    }
}

#Preview {
    AudioView()
}
