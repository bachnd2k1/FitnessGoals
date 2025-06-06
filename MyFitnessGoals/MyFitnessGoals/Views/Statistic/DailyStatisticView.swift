//
//  StatisticCalendarView.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 11/3/25.
//

import SwiftUI

struct DailyStatisticView: View {
    @StateObject var viewModel: StatisticViewModel
    @Binding var showDailyStats: Bool
    let dataManager: CoreDataManager
    @State private var selectedDate = Date()
    init(showDailyStats: Binding<Bool>, dataManager: CoreDataManager) {
        self._showDailyStats = showDailyStats
        self.dataManager = dataManager
        self._viewModel = StateObject(wrappedValue: StatisticViewModel(dataManager: dataManager))
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold) // Change size here
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                MonthCalendarView(selectedDate: $selectedDate) { day in
                    viewModel.selectedDate = day
                }
                .frame(height: 400)
                
                ScrollView {
                    HStack(spacing: 5) {
                        ForEach(viewModel.measures, id: \.type) { measure in
                            let date = measure.date
                            let type = measure.type
                            let value = measure.value
                            
                            if isSameDate(viewModel.selectedDate, and: date) {
                                MeasureDonutView(
                                    measure: value,
                                    formattedMeasure: formattedMeasure(measure: type, value: value),
                                    unitOfMeasure: type.unitOfMeasure,
                                    icon: type.icon,
                                    goal: viewModel.getGoal(for: type),
                                    height: geo.size.height / 2,
                                    width: geo.size.width / 3 - 10
                                )
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .onAppear {
                print("Measure value \(viewModel.measures)")
            }
            .onChange(of: viewModel.selectedDate) { _ in
                viewModel.fetchMeasures()
            }
            .navigationBarTitle("Daily Stats", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showDailyStats = false
                    }) {
                        Image(systemName: "chevron.left") // Default back icon
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    private func isSameDate(_ date1: Date, and date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    private func formattedMeasure(measure: MeasureUnit, value: Double) -> String {
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = measure == .distance ? 1 : 0
            formatter.minimumFractionDigits = measure == .distance ? 1 : 0
            formatter.locale = Locale(identifier: "en_US")
            return formatter
        }()
        return formatter.string(for: value) ?? ""
    }
}

#Preview {
    DailyStatisticView(showDailyStats: .constant(false), dataManager: .preview)
}
