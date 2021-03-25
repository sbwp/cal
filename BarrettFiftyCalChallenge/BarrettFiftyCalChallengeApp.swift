//
//  BeaFiftyCalChallengeApp.swift
//  BeaFiftyCalChallenge
//
//  Created by Sabrina Bea on 3/21/21.
//

import SwiftUI

@main
struct BeaFiftyCalChallengeApp: App {
    @StateObject var model: AppModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
