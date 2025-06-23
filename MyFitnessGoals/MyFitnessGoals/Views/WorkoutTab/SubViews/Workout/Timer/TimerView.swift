//
//  TimerView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var router: MobileNavigationRouter
    @Binding var errorLocationIsThrown: Bool
    @Binding var locationAccessIsDenied: Bool
    
    @Binding var errorMocationIsThrown: Bool
    @Binding var motionAccessIsDenied: Bool
    
    @State private var maxWidth: CGFloat = 0
    let elapsedTime: TimeInterval
    let timerIsNil: Bool
    let timerIsPaused: Bool
    let startAction: () -> ()
    let pauseAction: () -> ()
    let resumeAction: () -> ()
    let stopAction: () -> ()

    var body: some View {
        VStack {
            if errorLocationIsThrown  {
                Text("Location Access Error")
                    .font(.title)
                    .foregroundStyle(Color.accentColor)
            } else if errorMocationIsThrown {
                Text("Motion Access Error")
                    .font(.title)
                    .foregroundStyle(Color.accentColor)
            } else {
                Grid(alignment: .center) {
                    GridRow {
                        MetricView(value: viewModel.steps?.valueString ?? "0", label: "Steps",
                            icon: "figure.walk",
                            color: .yellow)
                        MetricView(value: formatTimeIntervalToString(elapsedTime), label: "Duration",
                            icon: "stopwatch",
                            color: .green)
                        MetricView(
                            value: distanceFormatter(for: viewModel.distance?.measure.value) ?? "0",
                            label: MeasureUnit.distance.unitOfMeasure,
                            icon: "mappin.and.ellipse",
                            color: .brown)
                    }
                    
                    GridRow {
                        MetricView(
                            value: viewModel.calories?.value == 0
                            ? "0"
                            : (commaFormatter.string(from: NSNumber(value: viewModel.calories?.value ?? 0)) ?? "0"),
                            label: MeasureUnit.calorie.unitOfMeasure,
                            icon: "flame.fill",
                            color: .orange)

                        MetricView(
                            value: speedFormatter(for: viewModel.speed?.measure.value) ?? "0",
                            label: MeasureUnit.speed.unitOfMeasure,
                            icon: "speedometer",
                            color: .green)
                        
                        MetricView(
                            value: {
                                if let heartRate = router.heartRate {
                                    return heartRate == 0.0 ? "-" : String(heartRate)
                                } else {
                                    return "-"
                                }
                            }(),
                            label: MeasureUnit.heartRate.unitOfMeasure,
                            icon: "heart.fill",
                            color: .red)
                    }
                }
            }
            HStack(spacing: 10) {
                if timerIsNil {
                    TimerButtonView(label: (viewModel.motionAccessIsDenied || viewModel.locationAccessIsDenied) ? L10n.settingBtn : L10n.startBtn, color: .green, disabled: false) {
                        startAction()
                    }
                } else {
                    if  locationAccessIsDenied {
                        TimerButtonView(label: L10n.settingBtn, color: .green, disabled: false) {
                            startAction()
                        }
                    } else {
                        if !errorLocationIsThrown && !errorMocationIsThrown {
                            if timerIsPaused {
                                TimerButtonView(label: "Resume", color: .green, disabled: false, equalWidth: true) {
                                    resumeAction()
                                }
                            } else {
                                TimerButtonView(label: "Pause", color: .yellow, disabled: false, equalWidth: true) {
                                    pauseAction()
                                }
                            }
                            TimerButtonView(label: "Stop", color: .red, disabled: false, equalWidth: true) {
                                stopAction()
                            }
                        }
                    }
                }
            }
            .padding(.top, 15)
            
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.black.opacity(0.7))
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
        return formatter.string(for: (valueInMetersPerSecond * 3.6))
    }
}


struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = WorkoutViewModel(dataManager: .preview, type: nil, healthKitManager: .shared, workoutSessionManager: WorkoutSessionManager.shared)
        TimerView(
            viewModel: viewModel,
            errorLocationIsThrown: .constant(false),
            locationAccessIsDenied: .constant(false),
            errorMocationIsThrown: .constant(false),
            motionAccessIsDenied: .constant(false),
            elapsedTime: 5130,
            timerIsNil: false,
        timerIsPaused: false
        ) {
            
        } pauseAction: {
            
        } resumeAction: {
            
        } stopAction: {
            
        }
        .environmentObject(MobileNavigationRouter())
    }
}
