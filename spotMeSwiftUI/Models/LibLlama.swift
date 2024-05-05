//
//  LibLlama.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 03/05/24.
//

import Foundation
import llama

enum llamaError: Error {
    case couldNotInitializeContext
}

func llama_batch_clear(_ batch: inout llama_batch) {
    batch.n_tokens = 0
}
