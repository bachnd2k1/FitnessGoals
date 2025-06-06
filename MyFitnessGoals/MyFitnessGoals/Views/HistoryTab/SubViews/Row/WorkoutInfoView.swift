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
        VStack {
            LabeledContent {
                HStack {
                    Text("Duration")
                    Spacer()
                    Text(durationFormatter(for: workout?.duration) ?? "")
                }
            } label: {
                Image(systemName: "timer")
                    .padding(.horizontal, 5)
                    .foregroundStyle(themeManager.isDarkMode ? Color.orange : Color.accentColor)
            }
            LabeledContent {
                HStack {
                    Text("Distance")
                    Spacer()
                    Text(distanceFormatter(for: workout?.distance?.measure) ?? "")
                    + Text(" \(workout?.distance?.type.unitOfMeasure ?? "")")
                }
            } label: {
                Image(systemName: workout?.distance?.type.icon ?? "")
                    .padding(.horizontal, 1)
                    .foregroundStyle(themeManager.isDarkMode ? Color.orange : Color.accentColor)
            }
            if isDisplayAll {
                LabeledContent {
                    HStack {
                        Text("Average Speed")
                        Spacer()
                        Text(speedFormatter(for: workout?.speed?.measure) ?? "")
                        + Text(" \(workout?.speed?.type.unitOfMeasure ?? "")")
                    }
                } label: {
                    Image(systemName: workout?.speed?.type.icon ?? "")
                        .padding(.horizontal, 5)
                        .foregroundStyle(themeManager.isDarkMode ? Color.orange : Color.accentColor)
                }
                if workout?.type != .cycling {
                    LabeledContent {
                        HStack {
                            Text("Steps")
                            Spacer()
                            Text(numberFormatterInteger.string(for: workout?.steps?.count ?? 0) ?? "")
                        }
                    } label: {
                        Image(systemName: workout?.steps?.type.icon ?? "")
                            .padding(.horizontal, 5)
                            .foregroundStyle(themeManager.isDarkMode ? Color.orange : Color.accentColor)
                    }
                }
                LabeledContent {
                    HStack {
                        Text("Calories")
                        Spacer()
                        Text(numberFormatterInteger.string(for : workout?.calories?.count ?? 0) ?? "")
                        + Text(" \(workout?.calories?.type.unitOfMeasure ?? "")")
                    }
                } label: {
                    Image(systemName: workout?.calories?.type.icon ?? "")
                        .padding(.horizontal, 5)
                        .foregroundStyle(themeManager.isDarkMode ? Color.orange : Color.accentColor)
                }
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
}

//struct WorkoutInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkoutInfoView()
//    }
//}
