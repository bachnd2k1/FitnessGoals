//
//  StatisticChartData.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 03/02/2025.
//

import Foundation

struct StatisticChartData: Identifiable, Equatable {
    let id = UUID()
    let measure: MeasureUnit
    let date: Date
    let metric: Double
}
