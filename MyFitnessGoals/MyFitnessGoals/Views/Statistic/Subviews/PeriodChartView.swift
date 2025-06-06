//
//  PeriodChartView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 03/02/2025.
//

import SwiftUI
import Charts

struct PeriodChartView: View {
    @Binding var selection: Period
    @State var type: MeasureUnit
    @State var newData: [StatisticChartData] = []
    let models: [BaseFitnessModel]
    var data: [StatisticChartData] {
        getChartData(models: models)
    }
    
    
    var body: some View {
        VStack {
            Chart(data) { element in
                BarMark(
                    x: .value("Date", element.date, unit: .day),
                    y: .value(element.measure.name, element.metric)
                )
                .opacity(0.5)
                RuleMark(y: .value("Goal", getGoal(for: element.measure)))
                .lineStyle(StrokeStyle(lineWidth: 1))
                .annotation(position: .top, alignment: .leading) {
                    Text(getFormattedGoal(for: element.measure))
                        .padding(.horizontal, 5)
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .chartXScale(domain: selection.domain)
            .aspectRatio(3, contentMode: .fit)
            .chartXAxis {
                AxisMarks(values: .stride(by: selection.stride)) { date in
                    AxisGridLine()
                    AxisValueLabel(format: selection.formatStyle, centered: true)
                }
            }
        }
    }
    
    func getChartData(models: [BaseFitnessModel]) -> [StatisticChartData]  {
        var newData: [StatisticChartData] = []
        for index in 0..<models.count {
            let date = models[index].date
            let type = models[index].type
            let value = models[index].value
            newData.append(
                StatisticChartData(
                    measure: type,
                    date: date ?? Date(),
                    metric: value
                )
            )
        }
        return newData
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
        return "Goal: " + goal + " " + measure.unitOfMeasure
    }
}

struct PeriodChartView_Previews: PreviewProvider {
    static let viewModel = StatisticViewModel(dataManager: .preview)
    static var previews: some View {
        PeriodChartView(selection: .constant(Period.week), type: .speed, models: viewModel.distances)
    }
}
