//
//  WorkoutDateAndTypeView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 24/01/2025.
//

import SwiftUI

struct WorkoutDateAndTypeView: View {
    let workout: Workout?
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        HStack {
            Text(workout?.date?.formatted(date: .abbreviated, time: .omitted).uppercased() ?? "")
            Spacer()
            Text(workout?.date?.formatted(date: .omitted, time: .shortened) ?? "")
        }
        .font(.title2)
        .fontWeight(.bold)
        .foregroundStyle(themeManager.isDarkMode ? Color.orange : Color.accentColor)
        
        HStack {
            Text(workout?.type?.name ?? "")
                .padding(5)
                .font(.caption)
                .foregroundStyle(.white)
                .background(Color.accentColor.opacity(0.7))
                .cornerRadius(8)
            Spacer()
        }
    }
}

//struct WorkoutDateAndTypeView_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkoutDateAndTypeView()
//    }
//}
