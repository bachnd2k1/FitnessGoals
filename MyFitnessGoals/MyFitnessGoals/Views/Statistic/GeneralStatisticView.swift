//
//  GeneralStatisticView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 03/02/2025.
//

import SwiftUI

struct GeneralStatisticView: View {
    @StateObject var viewModel: StatisticViewModel
    @State private var selection: Period = .week
    @State private var showDailyStats = false
    let dataManager: CoreDataManager
    
    init(dataManager: CoreDataManager) {
        self.dataManager = dataManager
        self._viewModel = .init(wrappedValue: StatisticViewModel(dataManager: dataManager))
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    Picker("", selection: $selection) {
                        ForEach(Period.allCases, id: \.self) { period in
                            Text(period.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                    .background(Color(UIColor.secondarySystemBackground))
                    Group {
                        VStack(alignment: .leading) {
                            Text("Distance travelled")
                                .font(.subheadline)
                            PeriodChartView(
                                selection: $selection,
                                type: .distance,
                                models: viewModel.distances)
                        }
                        VStack(alignment: .leading) {
                            Text("Calories burned")
                            PeriodChartView(
                                selection: $selection,
                                type: .calorie,
                                models: viewModel.calories)
                        }
                        VStack(alignment: .leading) {
                            Text("Steps taken")
                            PeriodChartView(
                                selection: $selection,
                                type: .step,
                                models: viewModel.steps)
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
            .navigationBarTitle("Statistics", displayMode: .inline)
//            .toolbar {
//                Button {
//                    withAnimation {
//                        showDailyStats.toggle()
//                    }
//                } label: {
//                    Image(systemName: "calendar")
//                        .font(.title2)
//                }
//                .fullScreenCover(isPresented: $showDailyStats) {
//                    NavigationStack {
//                        DailyStatisticView(showDailyStats: $showDailyStats, dataManager: dataManager)
//                    }
//                }
//            }
            
        }
        .background(Color(hex: "#F2F2F7"))
    }
    
}

struct GeneralStatisticView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralStatisticView(dataManager: CoreDataManager.shared)
    }
}
