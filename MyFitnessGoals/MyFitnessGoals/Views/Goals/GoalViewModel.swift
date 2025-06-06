//
//  GoalViewModel.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 04/02/2025.
//

import Foundation
import Combine

@MainActor
final class GoalViewModel: ObservableObject {
    private let calendarManager = CalendarManager()
    private let dataManager: CoreDataManager
    private let healthKitManager: HealthKitManager
    var distances: [Distance] = []
    var calories: [Calorie] = []
    var steps: [Step] = []
    var targetGoals: [TargetGoal] = []
    
    @Published var targetGoal: TargetGoal?
    @Published var selectedDate = Date()
    @Published var isAuthorized: Bool = false
    
    @Published var chartKitData: [ChartDataKit] = []
    let maxItem = 7
    
    @Published var distancesKit: [String]
    @Published var stepsKit: [String]
    @Published var caloriesKit: [String]
    
    @Published var selectedGoalIndex: Int = 0
    @Published var percentageValue = "0"
    
    
    var data = [
        ChartDataKit(day: "Sat", value: "4935"),
        ChartDataKit(day: "Sun", value: "3959"),
        ChartDataKit(day: "Mon", value: "7815"),
        ChartDataKit(day: "Tue", value: "5483"),
        ChartDataKit(day: "Wed", value: "7213"),
        ChartDataKit(day: "Thu", value: "5066"),
        ChartDataKit(day: "Fri", value: "748")
    ]
    
    var distancesChartData = [ChartDataKit]()
    var stepsKitChartData  = [ChartDataKit]()
    var caloriesKitChartData  = [ChartDataKit]()
    
    
    //    @State private var selectedStatIndex: Int = 0
    @Published var infoType: InfoType = .distance
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(dataManager: CoreDataManager, healthKitManager: HealthKitManager) {
        self.dataManager = dataManager
        self.healthKitManager = healthKitManager
        distancesKit = Array(repeating: "0", count: maxItem)
        stepsKit = Array(repeating: "0", count: maxItem)
        caloriesKit = Array(repeating: "0", count: maxItem)
        
        calendarManager.$selectedDate.assign(to: &$selectedDate)
        fetchInfo(date: Date())
        summerizeData()
        
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
        
        healthKitManager.$isAuthorized
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthorized)
        
        healthKitManager.distanceSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] distances in
                guard let self = self else { return }
                self.distancesKit = distances
                self.distancesChartData = generateChartData(from: distances)
            }
            .store(in: &cancellables)
        
        healthKitManager.stepSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] steps in
                guard let self = self else { return }
                self.stepsKit = steps
                self.stepsKitChartData = generateChartData(from: steps)
            }
            .store(in: &cancellables)
        
        healthKitManager.caloriesSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] calories in
                guard let self = self else { return }
                self.caloriesKit = calories
                self.caloriesKitChartData = generateChartData(from: calories)
            }
            .store(in: &cancellables)
        
        // Update chart when infoType changes
        $infoType
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.selectTargetGoal(infoType: newValue)
                self.updateChartData()
            }
            .store(in: &cancellables)
        
        $targetGoal
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.percentageValue = calculatePercentage()
            }
            .store(in: &cancellables)
    }
    
    public func updateChartData() {
        chartKitData = getData(infoType: infoType)
    }
    
    private func generateDefaultChartData() -> [ChartDataKit] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE" // "Sat", "Sun", etc.
        
        let today = Date()
        var chartData: [ChartDataKit] = []
        
        for i in 0..<7 {
            let pastDate = Calendar.current.date(byAdding: .day, value: -i, to: today) ?? today
            let dayString = dateFormatter.string(from: pastDate)
            chartData.append(ChartDataKit(day: dayString, value: "0"))
        }
        return chartData
    }
    
    func requestHealthKitPermssion() {
        healthKitManager.requestAuthorization()
    }
    
    func checkAuthorizationStatus() {
        healthKitManager.updateAuthorizationStatus()
    }
    
    func fetchInfo(date: Date) {
        healthKitManager.fetchHealthDataForLast7Days(date: date)
    }
    
    func summerizeData() {
        let filteredDistances = distances.filter { isSameDate(date1: $0.date!, date2: selectedDate) }
        let filteredCalories = calories.filter { isSameDate(date1: $0.date!, date2: selectedDate) }
        let filteredSteps = steps.filter { isSameDate(date1: $0.date!, date2: selectedDate) }
        
        
        let totalDistance = filteredDistances.reduce(0) { $0 + $1.value }
        let totalCalories = filteredCalories.reduce(0) { $0 + $1.value }
        let totalSteps = filteredSteps.reduce(0) { $0 + $1.value }
        
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 1
            formatter.minimumFractionDigits = 1
            formatter.locale = Locale(identifier: "en_US")
            return formatter
        }()
        
        targetGoals = [
            TargetGoal(
                measureType: MeasureUnit.distance.name,
                targetValue: getFormattedGoal(for: .distance),
                unitOfMeasure: MeasureUnit.distance.unitOfMeasure,
                icon: "location",
                color: .brown,
                measureValue: formatter.string(for: totalDistance)
            ),
            TargetGoal(
                measureType: MeasureUnit.step.name,
                targetValue: getFormattedGoal(for: .step),
                unitOfMeasure: MeasureUnit.step.unitOfMeasure,
                icon: "figure.walk",
                color: .brown,
                measureValue: formatter.string(for: totalSteps)
            ),
            TargetGoal(
                measureType: MeasureUnit.calorie.name,
                targetValue: getFormattedGoal(for: .calorie),
                unitOfMeasure: MeasureUnit.calorie.unitOfMeasure,
                icon: "flame",
                color: .brown,
                measureValue: formatter.string(for: totalCalories)
            )
        ]
    }
    
    
    func selectTargetGoal(index: Int) {
        targetGoal = targetGoals[index]
    }
    
    func updateSelectType(infoType: InfoType) {
        self.infoType = infoType
    }
    
    func selectTargetGoal(infoType: InfoType) {
        switch infoType {
        case .distance:
            targetGoal = targetGoals[0]
        case .step:
            targetGoal = targetGoals[1]
        case .calories:
            targetGoal = targetGoals[2]
        }
    }
    
    public func calculatePercentage() -> String {
        switch infoType {
        case .distance:
            let value = distancesKit[maxItem - selectedGoalIndex - 1]
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
            let value = stepsKit[maxItem - selectedGoalIndex - 1]
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
            let value = caloriesKit[maxItem - selectedGoalIndex - 1]
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
            return distancesKit[maxItem - indexPageDay - 1]
        case .step:
            return stepsKit[maxItem - indexPageDay - 1]
        case .calories:
            return caloriesKit[maxItem - indexPageDay - 1]
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
        switch measure {
        case .distance: return UserDefaults.standard.double(forKey: UserDefaults.Keys.distance.rawValue)
        case .calorie: return Double(UserDefaults.standard.integer(forKey: UserDefaults.Keys.calories.rawValue))
        case .step: return Double(UserDefaults.standard.integer(forKey: UserDefaults.Keys.steps.rawValue))
        default: return 0
        }
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
    
    private func isSameDate(date1: Date, date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
}
