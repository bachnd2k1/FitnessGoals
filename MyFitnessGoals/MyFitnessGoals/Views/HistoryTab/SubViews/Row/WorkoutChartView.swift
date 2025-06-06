//
//  WorkoutChartView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import SwiftUI
import Charts

struct WorkoutChartView: View {
    let workout: Workout?
    let metric: MetricType
    @StateObject var viewModel: HistoryViewModel
    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.chartData.map({ $0.distance }).reduce(0, +) > 0 {
                Text(metric == .cadence
                     ? workout?.type == .cycling ? "Speed" : "Pace"
                     : "Altitude")
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                Chart(viewModel.chartData) { element in
                    if metric == .altitude {
                        LineMark(
                            x: .value("Distance", element.distance),
                            y: .value("Speed", element.metric))
                    }
                    if metric == .cadence {
                        AreaMark(
                            x: .value("Distance", element.distance),
                            y: .value("Speed", element.metric))
                        .opacity(0.3)
                        RuleMark(y: .value("Average", viewModel.averageNum))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                            .annotation(position: .top, alignment: .leading) {
                                Text(viewModel.averageMetric)
                                    .padding(.horizontal, 5)
                                    .font(.caption)
                                    .foregroundStyle(Color.accentColor)
                            }
                    }
                }
                .chartXAxis{
                    AxisMarks(values: .automatic(minimumStride: 0.2, desiredCount: 6))
                }
                .chartYAxis{
                    AxisMarks(values: .automatic(minimumStride: 2, desiredCount: 6))
                }
                .chartPlotStyle { plotArea in
                    plotArea.background(Color.accentColor.opacity(0.3))
                        .border(Color.accentColor, width: 1)
                }
            }
        }
        .padding(.vertical)
        .onAppear {
            viewModel.calculateAverage(workout: workout, metric: metric)
            viewModel.getChartData(metric: metric, workout: workout)
        }
    }
    
    private func paceFormatter(for speed: Measurement<UnitSpeed>?) -> Double {
        guard let speedInMetersPerSecond = speed else { return 0 }
        return 1000 / 60 / speedInMetersPerSecond.value // min/km
    }
}

//struct WorkoutChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkoutChartView()
//    }
//}
