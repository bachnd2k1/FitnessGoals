//
//  DetailHistoryView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import SwiftUI

struct DetailHistoryView: View {
    let workout: Workout?
    @StateObject var viewModel: HistoryViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1 / UIScreen.main.scale)
                    .frame(maxWidth: .infinity)
                
                VStack {
                    WorkoutDateAndTypeView(workout: workout)
                    MapView(
                        mapType: .stationary,
                        startLocation: workout?.route?.first,
                        route: workout?.route ?? [],
                        endLocation: workout?.route?.last,
                        isFullScreen: .constant(false)
                    )
                    .frame(height: geometry.size.height / 2.5)
//                    WorkoutMetricsView(workout: workout, allMetrics: true)
                    WorkoutInfoView(workout: workout, isDisplayAll: true, viewModel: viewModel)
                    WorkoutChartView(workout: workout, metric: MetricType.cadence, viewModel: viewModel)
                        .frame(height: geometry.size.height / 3.5)
                    WorkoutChartView(workout: workout, metric: MetricType.altitude, viewModel: viewModel)
                        .frame(height: geometry.size.height / 3.5)
                        .offset(y: -30)
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

//struct DetailHistoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailHistoryView()
//    }
//}
