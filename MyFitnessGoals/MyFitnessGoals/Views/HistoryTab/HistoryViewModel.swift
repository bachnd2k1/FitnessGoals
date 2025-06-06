//
//  HistoryViewModel.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 24/01/2025.
//

import Foundation
import Combine

final class HistoryViewModel: ObservableObject {
    private let dataManager: CoreDataManager
    @Published var filteredType: FilteredType = .all
    @Published var filteredWorkouts: [Workout] = []
    @Published var chartData: [HistoryChartData] = []
    @Published var averageNum: Double = 0.0
    @Published var averageMetric: String = ""
    private var cancellables: Set<AnyCancellable> = []
    
    init(dataManager: CoreDataManager = CoreDataManager.shared) {
        self.dataManager = dataManager
        dataManager.$filteredWorkouts
            .sink { [weak self] in
                self?.filteredWorkouts = $0.map({ dataManager.nSManagedObjectToWorkout($0) })
            }
            .store(in: &cancellables)
    }
    
    func filterWorkouts() {
        dataManager.filterWorkouts(predicate: filteredType)
    }
    
    func delete(_ workout: Workout) {
        dataManager.delete(dataManager.workoutToNSManagedObject(workout))
        filterWorkouts()
        if let index = filteredWorkouts.firstIndex(where: { $0.id == workout.id }) {
            filteredWorkouts.remove(at: index)
        }
    }
    
    
    func getChartData(metric: MetricType, workout: Workout?) {
        Just(metric)
            .map { [weak self] metric -> [HistoryChartData] in
                guard let _ = self else { return [] }
                var data: [HistoryChartData] = []
                
                switch metric {
                case .cadence:
                    for index in 0..<(workout?.distances?.count ?? 0) {
                        data.append(
                            HistoryChartData(
                                distance: workout?.distances?[index].value ?? 0,
                                metric: workout?.type == .cycling
                                    ? workout?.speeds?[index].converted(to: .kilometersPerHour).value ?? 0
                                    : paceFormatter(for: workout?.speeds?[index])
                            )
                        )
                    }
                case .altitude:
                    for index in 0..<(workout?.distances?.count ?? 0) {
                        data.append(
                            HistoryChartData(
                                distance: workout?.distances?[index].value ?? 0,
                                metric: workout?.altitudes?[index].value ?? 0
                            )
                        )
                    }
                }
                return data
            }
            .assign(to: &$chartData)
    }
    
    private func paceFormatter(for speed: Measurement<UnitSpeed>?) -> Double {
        guard let speedInMetersPerSecond = speed else { return 0 }
        return 1000 / 60 / speedInMetersPerSecond.value // min/km
    }
    
    func calculateAverage(workout: Workout?, metric: MetricType) {
        guard let workout = workout else { return }
        averageNum = getAverage(workout: workout)
        guard let workoutType = workout.type else {
            averageMetric = "N/A"
            return
        }
        switch workoutType {
        case .cycling:
            let speed = workout.speed?.value ?? 0
            averageMetric = "Average speed: \(formatter.string(for: speed) ?? "") km/h"
        default:
            let pace = paceFormatter(for: workout.speed?.measure)
            averageMetric = "Average pace: \(formatter.string(for: pace) ?? "") min/km"
        }
    }
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    private func getAverage(workout: Workout) -> Double {
        switch workout.type {
        case .cycling: return workout.speed?.value ?? 0
        default: return paceFormatter(for: workout.speed?.measure)
        }
    }
    
    
}
