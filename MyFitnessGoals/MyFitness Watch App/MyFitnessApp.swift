//
//  MyFitnessApp.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 18/4/25.
//

import SwiftUI

@main
struct MyFitness_Watch_AppApp: App {
    init() {
        UserDefaults.setDefaultValues()
        _ = WatchSessionManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel())
        }
    }
}
