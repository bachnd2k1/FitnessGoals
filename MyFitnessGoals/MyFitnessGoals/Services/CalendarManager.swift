//
//  CalendarManager.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 03/02/2025.
//

import Foundation

final class CalendarManager: ObservableObject {
    private let calendar = Calendar.current
    @Published var weeks: [[Date]] = []
    @Published var selectedDate = Date()
    
    init() {
        updateWeeks(date: selectedDate)
    }
    
    func update(direction: TimeDirection) {
        selectedDate = updateWeekDay(direction: direction)
        updateWeeks(date: selectedDate)
    }
    
    private func updateWeeks(date: Date) {
        if let prevWeek = calendar.date(byAdding: .day, value: -7, to: date) {
            let week = fetchWeek(date: prevWeek)
            weeks.append(week)
        }
        
        weeks.append(fetchWeek(date: date))
        
        if let nextWeek = calendar.date(byAdding: .day, value: 7, to: date) {
            let week = fetchWeek(date: nextWeek)
            weeks.append(week)
        }
    }
    
    private func fetchWeek(date: Date) -> [Date] {
        var result: [Date] = []
        let week = calendar.dateInterval(of: .weekOfMonth, for: date)
        
        // get first day in a week
        guard let firstDayInWeek = week?.start else { return [] }
        
        // loop 0 - 6 and add with first day in a week to help add day into firstWeekday
        (0...6).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstDayInWeek) {
                result.append(weekday)
            }
        }
        return result
    }
    
    private func updateWeekDay(direction: TimeDirection) -> Date {
        switch direction {
        case .next:
            guard let date = calendar.date(byAdding: .day, value: 7, to: selectedDate) else {
                return Date()
            }
            guard let week = calendar.dateInterval(of: .weekOfMonth, for: date) else {
                return Date()
            }
            return week.start
        case .previous:
            guard let date = calendar.date(byAdding: .day, value: -7, to: selectedDate) else {
                return Date()
            }
            guard let week = calendar.dateInterval(of: .weekOfMonth, for: date) else {
                return Date()
            }
            return week.start
        case .none:
            return selectedDate
        }
    }
}

enum TimeDirection {
    case next
    case previous
    case none
}
