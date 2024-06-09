//
//  AuthViewModel.swift
//  CallindraFitness
//
//  Created by Pradeep Banavara on 05/06/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

class AuthViewModel: ObservableObject {
    
    enum signInState {
        case signedIn
        case signedOut
    }
    @Published var signedInState: signInState = .signedOut
    
}
