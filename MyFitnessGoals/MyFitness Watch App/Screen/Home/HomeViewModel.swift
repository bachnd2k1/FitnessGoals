//
//  HomeViewModel.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 29/4/25.
//

import Combine
import Foundation

class HomeViewModel: ObservableObject {
    
    @Published var targetGoal: TargetGoal?
    @Published var infoType: InfoType = .distance
    @Published var workoutType: WorkoutType = .walking
    @Published var targetGoals: [TargetGoal] = []
    
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.summerizeData()
        self.updateSelectType(infoType: .distance)
        // Update chart when infoType changes
        $infoType
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.selectTargetGoal(infoType: newValue)
            }
            .store(in: &cancellables)
    }
    
    func updateSelectType(infoType: InfoType) {
        self.infoType = infoType
    }
    
    func updateSelectWorkoutType(workoutType: WorkoutType) {
        self.workoutType = workoutType
    }
    
    private func selectTargetGoal(infoType: InfoType) {
       switch infoType {
       case .distance:
           targetGoal = targetGoals[0]
       case .step:
           targetGoal = targetGoals[1]
       case .calories:
           targetGoal = targetGoals[2]
       }
   }
    
    private func summerizeData() {
        targetGoals = [
            TargetGoal(
                measureType: MeasureUnit.distance.name,
                targetValue: getFormattedGoal(for: .distance),
                unitOfMeasure: MeasureUnit.distance.unitOfMeasure,
                icon: "location",
                color: .brown,
                infoType: .distance
            ),
            TargetGoal(
                measureType: MeasureUnit.step.name,
                targetValue: getFormattedGoal(for: .step),
                unitOfMeasure: MeasureUnit.step.unitOfMeasure,
                icon: "figure.walk",
                color: .brown,
                infoType: .step
            ),
            TargetGoal(
                measureType: MeasureUnit.calorie.name,
                targetValue: getFormattedGoal(for: .calorie),
                unitOfMeasure: MeasureUnit.calorie.unitOfMeasure,
                icon: "flame",
                color: .brown,
                infoType: .calories
            )
        ]
    }
    
    private func getGoal(for measure: MeasureUnit) -> Double {
        switch measure {
        case .distance: return UserDefaults.standard.double(forKey: UserDefaults.Keys.distance.rawValue)
        case .calorie: return Double(UserDefaults.standard.integer(forKey: UserDefaults.Keys.calories.rawValue))
        case .step: return Double(UserDefaults.standard.integer(forKey: UserDefaults.Keys.steps.rawValue))
        default: return 100
        }
    }
    
    private func getFormattedGoal(for measure: MeasureUnit) -> String {
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = measure == .distance ? 1 : 0
            formatter.minimumFractionDigits = 0 
            formatter.locale = Locale(identifier: "en_US")
            return formatter
        }()
        
        var goal: String = ""
        switch measure {
        case .distance: goal = formatter.string(for: getGoal(for: .distance)) ?? ""
        case .calorie: goal = formatter.string(for: getGoal(for: .calorie)) ?? ""
        case .step: goal = formatter.string(for: getGoal(for: .step)) ?? ""
        case .speed: goal = ""
        case .heartRate: goal = ""
        }
        return "\(goal) \(measure.unitOfMeasure)"
    }

}
