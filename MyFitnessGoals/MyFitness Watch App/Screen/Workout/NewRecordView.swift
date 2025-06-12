//
//  NewRecordView.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 9/6/25.
//

import Foundation
import SwiftUI

struct NewRecordView: View {
    @ObservedObject var viewModel: WatchWorkoutViewModel
    
    
    var body: some View {
        VStack {
            Grid(alignment: .center) {
                GridRow {
                    WatchMetricView(value: viewModel.steps?.valueString ?? "10", label: "Steps",
                        icon: "figure.walk",
                        color: .yellow)
                    WatchMetricView(value: formatTimeIntervalToString(viewModel.elapsedTime), label: "Duration",
                        icon: "stopwatch",
                        color: .green)
                    WatchMetricView(
                        value: distanceFormatter(for: viewModel.distance?.measure.value) ?? "10",
                        label: MeasureUnit.distance.unitOfMeasure,
                        icon: "mappin.and.ellipse",
                        color: .brown)
                }
                
                GridRow {
                    WatchMetricView(
                        value: viewModel.calories?.value == 0
                        ? "10"
                        : (commaFormatter.string(from: NSNumber(value: viewModel.calories?.value ?? 0)) ?? "0"),
                        label: MeasureUnit.calorie.unitOfMeasure,
                        icon: "flame.fill",
                        color: .orange)

                    WatchMetricView(
                        value: speedFormatter(for: viewModel.speed?.measure.value) ?? "10",
                        label: MeasureUnit.speed.unitOfMeasure,
                        icon: "speedometer",
                        color: .green)
                    
                    WatchMetricView(
                        value: {
                            if let heartRate = viewModel.currentHeartRate {
                                return heartRate.value == 0.0 ? "-" : String(heartRate.value)
                            } else {
                                return "-"
                            }
                        }(),
                        label: MeasureUnit.heartRate.unitOfMeasure,
                        icon: "heart.fill",
                        color: .red
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func formatTimeIntervalToString(_ elapsedTime: TimeInterval) -> String {
        let duration = Duration(
            secondsComponent: Int64(elapsedTime),
            attosecondsComponent: 0
        )
        
        if elapsedTime >= 3600 {
            return duration.formatted(.time(pattern: .hourMinuteSecond(padHourToLength: 2)))
        } else {
            return duration.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
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

    private let commaFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0  // No decimal places
        formatter.groupingSeparator = "."   // Set thousands separator if needed
        formatter.decimalSeparator = ","    // Use comma as decimal separator
        return formatter
    }()


    private func distanceFormatter(for value: Double?) -> String? {
        // conversion meters -> kilometers
        guard let valueInMeters = value else { return nil }
        return formatter.string(for: (valueInMeters / 1000))
    }

    private func speedFormatter(for value: Double?) -> String? {
        // conversion meters/second -> kilometers/hour
        guard let valueInMetersPerSecond = value else { return nil }
        return formatter.string(for: (valueInMetersPerSecond))
    }
}

#Preview {
    let viewModel = WatchWorkoutViewModel(router: WatchNavigationRouter(), type: .cycling)
    NewRecordView(viewModel: viewModel)
}
