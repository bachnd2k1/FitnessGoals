//
//  WorkoutInfoView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 24/01/2025.
//

import SwiftUI

struct WorkoutInfoView: View {
    let workout: Workout?
    let isDisplayAll: Bool
    @StateObject var viewModel: HistoryViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            rowView(icon: "timer", label: "Duration", value: durationFormatter(for: workout?.duration) ?? "")
            
            rowView(icon: workout?.distance?.type.icon ?? "", label: "Distance",
                    value: "\(distanceFormatter(for: workout?.distance?.measure) ?? "") \(workout?.distance?.type.unitOfMeasure ?? "")")
            
            if isDisplayAll {
                rowView(icon: workout?.speed?.type.icon ?? "", label: "Average Speed",
                        value: "\(speedFormatter(for: workout?.speed?.measure) ?? "") \(workout?.speed?.type.unitOfMeasure ?? "")")
                
                if workout?.type != .cycling {
                    rowView(icon: workout?.steps?.type.icon ?? "", label: "Steps",
                            value: numberFormatterInteger.string(for: workout?.steps?.count ?? 0) ?? "")
                }
                
                rowView(icon: workout?.calories?.type.icon ?? "", label: "Calories",
                        value: "\(numberFormatterInteger.string(for: workout?.calories?.count ?? 0) ?? "") \(workout?.calories?.type.unitOfMeasure ?? "")")
            }
        }
        .font(.subheadline)
    }
    private let numberFormatterInteger: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    private let numberFormatterDecimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        return formatter
    }()

    private func durationFormatter(for duration: TimeInterval?) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter.string(from: duration ?? 0)
    }

    private func distanceFormatter(for measure: Measurement<UnitLength>?) -> String? {
        guard let distanceInMeters = measure else { return nil }
        return numberFormatterDecimal.string(for: distanceInMeters.converted(to: UnitLength.kilometers).value)
    }

    private func speedFormatter(for measure: Measurement<UnitSpeed>?) -> String? {
        guard let speedInMetersPerSecond = measure else { return nil }
        return numberFormatterDecimal.string(for: speedInMetersPerSecond.converted(to: .kilometersPerHour).value)
    }
    
    @ViewBuilder
    private func rowView(icon: String, label: String, value: String) -> some View {
        HStack {
            // Icon + Text label
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .frame(width: 18)
                    .foregroundStyle(themeManager.isDarkMode ? .orange : .accentColor)
                Text(label)
            }
            
            Spacer(minLength: 20)
            
            Text(value)
        }
    }
}

//struct WorkoutInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkoutInfoView()
//    }
//}
