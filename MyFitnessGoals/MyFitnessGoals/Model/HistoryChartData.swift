//
//  ChartData.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import Foundation

struct HistoryChartData: Identifiable {
    let id = UUID()
    let distance: Double
    let metric: Double
}

enum MetricType {
    case cadence
    case altitude
}
