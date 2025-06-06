//
//  CalendarView.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 11/3/25.
// 

import Foundation
import SwiftUI

struct MonthCalendarView: View {
    @State private var currentYear = Calendar.current.component(.year, from: Date())
    @State private var currentMonth = Calendar.current.component(.month, from: Date())
    @Binding var selectedDate: Date
    let onDateSelected: (Date) -> Void
    
    var body: some View {
        VStack() {
            MonthYearPickerView(currentYear: $currentYear, currentMonth: $currentMonth, nextYear: nextYear, previousYear: previousYear, nextMonth: nextMonth, previousMonth: previousMonth)
            // Calendar Grid with Swipe Gesture
            TabView(selection: $currentMonth) {
                ForEach(1...12, id: \ .self) { month in
                    CalendarGrid(year: currentYear, month: month, selectedDate: $selectedDate) { day in
                        onDateSelected(day)
                    }
                    .tag(month)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .gesture(
                DragGesture().onEnded { value in
                    if value.translation.width < 0 { nextMonth() }  // Swipe left for next month
                    if value.translation.width > 0 { previousMonth() } // Swipe right for previous month
                }
            )
            .frame(maxHeight: 300)
            Spacer()
        }
//        .padding()
    }
    
    // Month Navigation
    private func previousMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
    }
    
    private func nextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
    }
    
    // Year Navigation
    private func previousYear() { currentYear -= 1 }
    private func nextYear() { currentYear += 1 }
}

struct MonthYearPickerView: View {
    @Binding var currentYear: Int
    @Binding var currentMonth: Int
    let nextYear: () -> Void
    let previousYear: () -> Void
    let nextMonth: () -> Void
    let previousMonth: () -> Void
    
    var displayedText: String {
        let calendar = Calendar.current
        let currentSystemYear = calendar.component(.year, from: Date())
        let monthName = calendar.standaloneMonthSymbols[currentMonth - 1]
        if currentYear == currentSystemYear {
            return monthName
        } else {
            return "\(currentYear) \(monthName)"
        }
    }

    
    var body: some View {
        VStack() {
            HStack {
//                Button(action: previousMonth) {
//                    Image(systemName: "chevron.left")
//                        .frame(width: 10, height: 10)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .clipShape(Circle())
//                }
                Spacer()
                Text(displayedText)
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
//                Button(action: nextMonth) {
//                    Image(systemName: "chevron.right")
//                        .frame(width: 10, height: 10)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .clipShape(Circle())
//                }
            }
        }
    }
}

// MARK: - Calendar Grid
struct CalendarGrid: View {
    let year: Int
    let month: Int
    @Binding var selectedDate: Date
    let onDateSelected: (Date) -> Void
    
    var body: some View {
        let days = generateDaysForMonth(year: year, month: month)
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
            // Weekday Headers
            ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \ .self) { day in
                Text(day).font(.caption).fontWeight(.bold)
            }
            
            // Days of the Month
            ForEach(days, id: \ .self) { day in
                if let day = day {
                    Text("\(day.getDay())")
                        .frame(width: 40, height: 40)
                        .background(isSameDate(selectedDate, and: day) ? Color.accentColor : Color.clear)
                        .clipShape(Circle())
                        .onTapGesture {
                            selectedDate = day
                            onDateSelected(day)
                        }
                } else {
                    Text("") // Empty slot for alignment
                }
            }
        }
    }
    
    private func generateDaysForMonth(year: Int, month: Int) -> [Date?] {
        var days: [Date?] = []
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month)
        
        if let firstDayOfMonth = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) {
            
            let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
            
            // Empty slots for alignment
            days.append(contentsOf: Array(repeating: nil, count: firstWeekday))
            
            // Days of the month
            for day in range {
                if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                    days.append(date)
                }
            }
        }
        return days
    }
    
    private func isSameDate(_ date1: Date, and date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}

// MARK: - Helper Extensions
extension Date {
    func getDay() -> Int {
        return Calendar.current.component(.day, from: self)
    }
}

// MARK: - Preview
struct MonthCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        MonthCalendarView(selectedDate: .constant(Date())) { _ in }
    }
}
