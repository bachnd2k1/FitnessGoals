//
//  GoalViewModel.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 04/02/2025.
//

import Foundation
import Combine

protocol GoalHealthDataProviding {
    var isAuthorizedPublisher: Published<Bool>.Publisher { get }
    var distancePublisher: AnyPublisher<[String], Never> { get }
    var stepPublisher: AnyPublisher<[String], Never> { get }
    var caloriesPublisher: AnyPublisher<[String], Never> { get }
    func requestAuthorization()
    func updateAuthorizationStatus()
    func fetchHealthDataForLast7Days(date: Date)
}

protocol GoalSettingsProviding {
    func goalValue(for measure: MeasureUnit) -> Double
}

struct UserDefaultsGoalSettingsProvider: GoalSettingsProviding {
    func goalValue(for measure: MeasureUnit) -> Double {
        switch measure {
        case .distance:
            return UserDefaults.standard.double(forKey: UserDefaults.Keys.distance.rawValue)
        case .calorie:
            return Double(UserDefaults.standard.integer(forKey: UserDefaults.Keys.calories.rawValue))
        case .step:
            return Double(UserDefaults.standard.integer(forKey: UserDefaults.Keys.steps.rawValue))
        default:
            return 0
        }
    }
}

@MainActor
final class GoalViewModel: ObservableObject {
    private let calendarManager: CalendarManager
    private let healthDataProvider: GoalHealthDataProviding
    private let settingsProvider: GoalSettingsProviding
    private var targetGoals: [TargetGoal] = []
    
    @Published var targetGoal: TargetGoal?
    @Published var selectedDate = Date()
    @Published var isAuthorized: Bool = false
    
    @Published var chartKitData: [ChartDataKit] = []
    let maxItem = 7
    
    @Published private var distancesKit: [String]
    @Published private var stepsKit: [String]
    @Published private var caloriesKit: [String]
    
    @Published var selectedGoalIndex: Int = 0
    @Published var percentageValue = "0"
    
    var distancesChartData = [ChartDataKit]()
    var stepsKitChartData  = [ChartDataKit]()
    var caloriesKitChartData  = [ChartDataKit]()
    
    
    //    @State private var selectedStatIndex: Int = 0
    @Published var infoType: InfoType = .distance
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        healthDataProvider: GoalHealthDataProviding,
        settingsProvider: GoalSettingsProviding = UserDefaultsGoalSettingsProvider(),
        calendarManager: CalendarManager = CalendarManager()
    ) {
        self.healthDataProvider = healthDataProvider
        self.settingsProvider = settingsProvider
        self.calendarManager = calendarManager
        distancesKit = Array(repeating: "0", count: maxItem)
        stepsKit = Array(repeating: "0", count: maxItem)
        caloriesKit = Array(repeating: "0", count: maxItem)
        
        calendarManager.$selectedDate.assign(to: &$selectedDate)
        fetchInfo(date: Date())
        summarizeData()
        
        healthDataProvider.isAuthorizedPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthorized)
        
        Publishers.CombineLatest3(
            healthDataProvider.distancePublisher,
            healthDataProvider.stepPublisher,
            healthDataProvider.caloriesPublisher
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] distances, steps, calories in
                guard let self = self else { return }
                self.distancesKit = distances
                self.stepsKit = steps
                self.caloriesKit = calories
                self.distancesChartData = generateChartData(from: distances)
                self.stepsKitChartData = generateChartData(from: steps)
                self.caloriesKitChartData = generateChartData(from: calories)
                self.updateChartData()
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest($infoType, $selectedGoalIndex)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] infoType, selectedIndex in
                guard let self = self else { return }
                self.targetGoal = self.targetGoal(for: infoType)
                self.chartKitData = self.getData(infoType: infoType)
                self.percentageValue = self.calculatePercentage(for: infoType, selectedIndex: selectedIndex)
            }
            .store(in: &cancellables)
    }
    
    public func updateChartData() {
        chartKitData = getData(infoType: infoType)
    }
    
    func requestHealthKitPermssion() {
        healthDataProvider.requestAuthorization()
    }
    
    func checkAuthorizationStatus() {
        healthDataProvider.updateAuthorizationStatus()
    }
    
    func fetchInfo(date: Date) {
        healthDataProvider.fetchHealthDataForLast7Days(date: date)
    }
    
    func summarizeData() {
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
    
    
    func selectTargetGoal(index: Int) {
        targetGoal = targetGoals[index]
    }
    
    func updateSelectType(infoType: InfoType) {
        self.infoType = infoType
    }
    
    public func calculatePercentage(for type: InfoType, selectedIndex: Int) -> String {
        switch type {
        case .distance:
            let value = value(for: distancesKit, at: selectedIndex)
            let targetValue = targetGoal?.targetValue
            guard let targetStr = targetValue,
                  let value = Double(value),
                  let targetValue = Double(targetStr),
                  targetValue > 0 else {
                return "0%"
            }
            
            let percentage = (value / targetValue) * 100
            return percentage.truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f%%", percentage) :
            String(format: "%.1f%%", percentage)
        case .step:
            let value = value(for: stepsKit, at: selectedIndex)
            let targetValue = targetGoal?.targetValue
            guard let targetStr = targetValue,
                  let value = Double(value), let targetValue = Double(targetStr), targetValue > 0 else {
                return "0%"
            }
            let percentage = (value / targetValue) * 100
            return  percentage.truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f%%", percentage) :
            String(format: "%.2f%%", percentage)
        case .calories:
            let value = value(for: caloriesKit, at: selectedIndex)
            let targetValue = targetGoal?.targetValue
            guard let targetStr = targetValue,
                  let value = Double(value), let targetValue = Double(targetStr), targetValue > 0 else {
                return "0%"
            }
            let percentage = (value / targetValue) * 100
            return percentage.truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f%%", percentage) :
            String(format: "%.2f%%", percentage)
        }
    }
    
    func getSelectedHealthKitValue(indexPageDay: Int) -> String {
        switch infoType {
        case .distance:
            return value(for: distancesKit, at: indexPageDay)
        case .step:
            return value(for: stepsKit, at: indexPageDay)
        case .calories:
            return value(for: caloriesKit, at: indexPageDay)
        }
    }
    
    func getData(infoType: InfoType) -> [ChartDataKit] {
        switch infoType {
        case .distance:
            return distancesChartData
        case .step:
            return stepsKitChartData
        case .calories:
            return caloriesKitChartData
        }
    }
    
    
    func generateChartData(from dataType: [String]) -> [ChartDataKit] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE" // "Sat", "Sun", etc.
        
        let today = Date()
        var chartData: [ChartDataKit] = []
        
        for i in 0..<7 {
            if i < dataType.count {
                let pastDate = Calendar.current.date(byAdding: .day, value: -i, to: today) ?? today
                let dayString = dateFormatter.string(from: pastDate)
                chartData.append(ChartDataKit(day: dayString, value: dataType[i]))
            }
        }
        return Array(chartData.reversed()) // No need to reverse since today is at index 0
    }
    
    private func getGoal(for measure: MeasureUnit) -> Double {
        settingsProvider.goalValue(for: measure)
    }
    
    private func getFormattedGoal(for measure: MeasureUnit) -> String {
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = measure == .distance ? 1 : 0
            formatter.minimumFractionDigits = measure == .distance ? 1 : 0
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
        return "\(goal)"
    }
    
    private func targetGoal(for infoType: InfoType) -> TargetGoal? {
        targetGoals.first { $0.infoType == infoType }
    }
    
    private func value(for data: [String], at selectedIndex: Int) -> String {
        guard selectedIndex >= 0, selectedIndex < maxItem else {
            return "0"
        }

        let index = maxItem - selectedIndex - 1
        guard index >= 0, index < data.count else {
            return "0"
        }

        return data[index]
    }
}

extension HealthKitManager: GoalHealthDataProviding {
    var isAuthorizedPublisher: Published<Bool>.Publisher { $isAuthorized }
    var distancePublisher: AnyPublisher<[String], Never> { distanceSubject.eraseToAnyPublisher() }
    var stepPublisher: AnyPublisher<[String], Never> { stepSubject.eraseToAnyPublisher() }
    var caloriesPublisher: AnyPublisher<[String], Never> { caloriesSubject.eraseToAnyPublisher() }
}
