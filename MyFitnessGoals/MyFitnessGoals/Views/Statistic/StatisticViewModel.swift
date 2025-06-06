//
//  StatisticViewModel.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 03/02/2025.
//

import Foundation
import Combine

@MainActor
final class StatisticViewModel: ObservableObject {
    private let calendarManager = CalendarManager()
    private let dataManager: CoreDataManager
    @Published var distances: [Distance] = []
    @Published var calories: [Calorie] = []
    @Published var steps: [Step] = []
    @Published var weeks: [[Date]] = []
    @Published var selectedDate = Date()
    @Published var measures: [(date: Date, type: MeasureUnit, value: Double)] = []
    @Published var data: [StatisticChartData] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(dataManager: CoreDataManager) {
        self.dataManager = dataManager
        calendarManager.$weeks.assign(to: &$weeks)
        calendarManager.$selectedDate.assign(to: &$selectedDate)
        dataManager.$distances
            .sink { [weak self] in
                self?.distances = $0.compactMap { dataManager.mapToBaseFitness($0) as? Distance }
            }
            .store(in: &cancellables)
        
        dataManager.$calories
            .sink { [weak self] in
                self?.calories = $0.compactMap { dataManager.mapToBaseFitness($0) as? Calorie }
            }
            .store(in: &cancellables)
        
        dataManager.$steps
            .sink { [weak self] in
                self?.steps = $0.compactMap{ dataManager.mapToBaseFitness($0) as? Step }
            }
            .store(in: &cancellables)
        
        fetchMeasures()
    }
    
    func fetchMeasures() {
        self.measures.removeAll()
        Dictionary(
            grouping: distances,
            by: { formatDate($0.date) }
        )
        .filter { isSameDate($0.key, and: selectedDate)}
        .forEach {
            self.measures.append(
                (date: $0,
                 type: MeasureUnit.distance,
                 value: $1.reduce(0, { $0 + $1.measure.converted(to: .kilometers).value }) )
            )
        }
        
        Dictionary(
            grouping: calories,
            by: { formatDate($0.date) }
        )
        .filter { isSameDate($0.key, and: selectedDate) }
        .forEach {
            self.measures.append(
                (date: $0,
                 type: MeasureUnit.calorie,
                 value: $1.reduce(0, { $0 + Double($1.count) }) )
            )
        }
        
        Dictionary(
            grouping: steps,
            by: { formatDate($0.date) }
        )
        .filter { isSameDate($0.key, and: selectedDate) }
        .forEach {
            self.measures.append(
                (date: $0,
                 type: MeasureUnit.step,
                 value: $1.reduce(0, { $0 + Double($1.count) }) )
            )
        }
        
//        let distanceModels: [BaseFitnessModel] = distances.filter { isSameDate($0.date!, and: selectedDate) }
//        let calorieModels: [BaseFitnessModel] = calories.filter { isSameDate($0.date!, and: selectedDate) }
//        let stepModels: [BaseFitnessModel] = steps.filter { isSameDate($0.date!, and: selectedDate) }
//
//        getChartData(models: distanceModels + calorieModels + stepModels)
    }
    
    func getGoal(for measure: MeasureUnit) -> Double {
        switch measure {
        case .distance: return UserDefaults.standard.double(forKey: UserDefaults.Keys.distance.rawValue)
        case .calorie: return Double(UserDefaults.standard.integer(forKey: UserDefaults.Keys.calories.rawValue))
        case .step: return Double(UserDefaults.standard.integer(forKey: UserDefaults.Keys.steps.rawValue))
        default: return 0
        }
    }
    
    private func formatDate(_ date: Date?) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = calendar.component(.day, from: date ?? Date())
        components.month = calendar.component(.month, from: date ?? Date())
        components.year = calendar.component(.year, from: date ?? Date())
        return calendar.date(from: components) ?? Date.now
    }

    private func isSameDate(_ date1: Date, and date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}
