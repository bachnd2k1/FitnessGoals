//
//  IncreaseGoalButtonView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 04/02/2025.
//

import SwiftUI

struct GoalButtonView: View {
    let icon: String
    let action: () -> Void
    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: icon)
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .frame(width: 50, height: 50)
                .background(Color.accentColor)
                .clipShape(Circle()) // Make the background a circle
                .foregroundColor(Color.white)
        }
    }
}

struct IncreaseGoalButtonView_Previews: PreviewProvider {
    static var previews: some View {
        GoalButtonView(icon: "plus") {}
    }
}
