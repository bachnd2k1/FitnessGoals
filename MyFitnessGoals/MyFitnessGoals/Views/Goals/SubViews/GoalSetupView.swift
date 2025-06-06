//
//  GoalSetupView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 04/02/2025.
//

import SwiftUI

struct GoalSetupView: View {
//    let measureType: String
//    let measureValue: String
//    let unitOfMeasure: String
//    let color: Color
    let targetGoal: TargetGoal
    let increaseAction: () -> Void
    let decreaseAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(targetGoal.measureType)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, 20)
            
            HStack {
                GoalButtonView(icon: "minus") {
                    decreaseAction()
                }
                
                Spacer()
                VStack {
                    Text(targetGoal.targetValue)
                    HStack {
                        Image(systemName: targetGoal.icon)
                            .foregroundColor(Color(uiColor: targetGoal.color))
                        Text(targetGoal.unitOfMeasure)
                    }
                }
                .font(.title)
                .fontWeight(.semibold)
                Spacer()
                GoalButtonView(icon: "plus") {
                    increaseAction()
                }
            }
        }
    }
}

struct GoalSetupView_Previews: PreviewProvider {
    static var targetGoal = TargetGoal(
        measureType: "Distance",
        targetValue: "5",
        unitOfMeasure: "km",
        icon: "location",
        color: .brown
    )
    static var previews: some View {
        GoalSetupView(
            targetGoal: targetGoal
        ) {} decreaseAction: {}
    }
}
