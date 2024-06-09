//
//  OnboardingView.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 30/05/24.
//

import SwiftUI
import AVKit

struct OnboardingView: View {
    private var pronouns = ["He", "She", "Them/Their"]
    private var ageRanges = ["18-25", "25-35", "35-45", "45-55", "55+"]
    private var regions = ["North America", "South Asia", "Europe", "APAC"]
    @State private var selectedAgeRange = "18-25"
    @State private var selectedPronoun = "He"
    @State private var selectedRegion: String = "North America"
    @State private var userEmail: String = ""
    @State private var userPhone: Double?
    @State private var strength = false
    @State private var pushups = false
    @State private var run5k = false
    @State private var endurance = false
    
    private var countries = ["+1", "+91", "+44"]
    @State private var selectedCountry: String = ""
    
    var body: some View {
        VStack {
            Text("Welcome to Callindra").foregroundStyle(
                LinearGradient(
                    colors: [.teal, .indigo],
                    startPoint: .top,
                    endPoint: .bottom
                )
            ).font(.title).padding()
            Image(.main).resizable().frame(width: 80, height: 80).scaledToFit()
            Text("Correct your workout form in realtime").foregroundStyle(.primary).multilineTextAlignment(.leading).padding()
            if let url = Bundle.main.url(forResource: "main_view_video", withExtension: "mov") {
                let player = AVPlayer(url: url)
                VideoPlayer(player: player)
                    .onAppear{
                        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
                                               player.seek(to: .zero)
                                               player.play()
                                           }
                        /*
                        if player.currentItem == nil {
                            let item = AVPlayerItem(url: url)
                            player.replaceCurrentItem(with: item)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            player.play()
                        })
                         */
                    }
            }
            
            
        }
    }
}

#Preview {
    OnboardingView()
}
