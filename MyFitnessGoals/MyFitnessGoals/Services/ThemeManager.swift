//
//  ThemeManager.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 24/01/2025.
//

import Foundation

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false

    func toggleTheme() {
        isDarkMode.toggle()
    }
}
