//
//  LlamaState.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 03/05/24.
//

import Foundation

struct Model: Identifiable {
    var id = UUID()
    var name: String
    var url: String
    var fileName: String
    var status: String?
}

@MainActor
class LlamaState: ObservableObject {
    @Published var messageLog = ""
    @Published var cacheCleared = false
    @Published var downloadedModels: [Model] = []
    @Published var undownloadedModels : [Model] = []
    let NS_PER_S = 1_000_000_000.0
}
