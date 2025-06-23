//
//  SetGoalsView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 04/02/2025.
//

import SwiftUI

struct SetGoalsView: View {
    @AppStorage(UserDefaults.Keys.distance.rawValue) private var distance: Double = 0
    @AppStorage(UserDefaults.Keys.calories.rawValue) private var calories: Int = 0
    @AppStorage(UserDefaults.Keys.steps.rawValue) private var steps: Int = 0
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack() {
                GoalSetupView(
                    targetGoal:
                        TargetGoal(
                            measureType: MeasureUnit.distance.name,
                            targetValue: getFormattedGoal(for: .distance), unitOfMeasure: MeasureUnit.distance.unitOfMeasure,
                            icon: "location",
                            color: .brown
                        )
                ){
                    increaseGoal(for: .distance)
                } decreaseAction: {
                    decreaseGoal(for: .distance)
                }
                
                GoalSetupView(
                    targetGoal:
                        TargetGoal(
                            measureType: MeasureUnit.calorie.name,
                            targetValue: getFormattedGoal(for: .calories),     unitOfMeasure: MeasureUnit.calorie.unitOfMeasure,
                            icon: "figure.walk",
                            color: .brown
                        )
                ) {
                    increaseGoal(for: .calories)
                } decreaseAction: {
                    decreaseGoal(for: .calories)
                }
                
                GoalSetupView(
                    targetGoal:
                        TargetGoal(
                            measureType: MeasureUnit.step.name,
                            targetValue: getFormattedGoal(for: .steps), unitOfMeasure: MeasureUnit.step.unitOfMeasure,
                            icon: "flame",
                            color: .brown
                        )
                ) {
                    increaseGoal(for: .steps)
                } decreaseAction: {
                    decreaseGoal(for: .steps)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .overlay(
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1 / UIScreen.main.scale)
                    .frame(maxWidth: .infinity)
                    .offset(y: -44),
                alignment: .top
            )
            //            .background(Color.red)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Set My Goal")
                        .font(.headline)
                        .bold()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func getFormattedGoal(for measure: UserDefaults.Keys) -> String {
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = measure == .distance ? 1 : 0
            formatter.minimumFractionDigits = measure == .distance ? 1 : 0
            formatter.locale = Locale(identifier: "en_US")
            return formatter
        }()
        
        switch measure {
        case .distance: return formatter.string(for: abs(distance)) ?? ""
        case .calories: return formatter.string(for: abs(Double(calories))) ?? ""
        case .steps: return formatter.string(for: abs(Double(steps))) ?? ""
        default: return ""
        }
    }
    
    private func decreaseGoal(for measure: UserDefaults.Keys) {
        switch measure {
        case .distance:
            if UserDefaults.standard.double(forKey: measure.rawValue) <= 0 {
                break
            } else { UserDefaults.standard.setValue(distance - 0.5, forKey: measure.rawValue)
            }
        case .calories:
            if UserDefaults.standard.double(forKey: measure.rawValue) <= 0 {
                break
            } else { UserDefaults.standard.setValue(calories - 50, forKey: measure.rawValue)
            }
        case .steps:
            if UserDefaults.standard.double(forKey: measure.rawValue) <= 0 {
                break
            } else {
                UserDefaults.standard.setValue(steps - 500, forKey: measure.rawValue)
            }
        default: break
        }
    }
    
    private func increaseGoal(for measure: UserDefaults.Keys) {
        switch measure {
        case .distance: UserDefaults.standard.setValue(distance + 0.5, forKey: measure.rawValue)
        case .calories: UserDefaults.standard.setValue(calories + 50, forKey: measure.rawValue)
        case .steps: UserDefaults.standard.setValue(steps + 500, forKey: measure.rawValue)
        default: break
        }
    }
}

struct SetGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        SetGoalsView()
    }
}
