//
//  Period.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 03/02/2025.
//

import Foundation

enum Period: String, CaseIterable {
    case week
    case month
    case year

    var domain: ClosedRange<Date> {
        switch self {
        case .week:
            return Calendar.current.date(
                byAdding: .day,
                value: -6,
                to: formatDate(Date.now))!...Calendar.current.date(
                    byAdding: .day,
                    value: 1,
                    to: formatDate(Date.now))!
        case .month:
            return Calendar.current.date(
                byAdding: .day,
                value: -29,
                to: formatDate(Date.now))!...Calendar.current.date(
                    byAdding: .day,
                    value: 1,
                    to: formatDate(Date.now))!
        case .year:
            return Calendar.current.date(
                byAdding: .month,
                value: -11,
                to: formatMonth(Date.now))!...Calendar.current.date(
                    byAdding: .month,
                    value: 1,
                    to: formatMonth(Date.now))!
        }
    }

    var stride: Calendar.Component {
        switch self {
        case .week:
            return .day
        case .month:
            return .day
        case .year:
            return .month
        }
    }

    var formatStyle: Date.FormatStyle {
        switch self {
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.weekday(.narrow)
        case .year:
            return .dateTime.month(.abbreviated)
        }
    }

    private func formatDate(_ date: Date?) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = calendar.component(.day, from: date ?? Date())
        components.month = calendar.component(.month, from: date ?? Date())
        components.year = calendar.component(.year, from: date ?? Date())
        return calendar.date(from: components) ?? Date.now
    }

    private func formatMonth(_ date: Date?) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = calendar.component(.month, from: date ?? Date())
        components.year = calendar.component(.year, from: date ?? Date())
        return calendar.date(from: components) ?? Date.now
    }
}
