//
//  HistoryView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 23/01/2025.
//

import SwiftUI

struct HistoryView: View {
    @StateObject var viewModel: HistoryViewModel
    @State private var isSelectingWorkout = false
    @State private var selectedWorkout: Workout?
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Int
    let dataManager: CoreDataManager
    
    init(dataManager: CoreDataManager, selectedTab: Binding<Int>) {
        self.dataManager = dataManager
        self._viewModel = .init(wrappedValue: HistoryViewModel(dataManager: dataManager))
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationStack {
            Rectangle()
                .fill(Color.gray)
                .frame(height: 1 / UIScreen.main.scale)
                .frame(maxWidth: .infinity)
            List {
                ForEach(viewModel.filteredWorkouts) { workout in
                    WorkoutRowView(viewModel: viewModel, workout: workout)
                        .onTapGesture {
                            selectedWorkout = workout
                        }
                        .navigationDestination(isPresented: .constant(selectedWorkout == workout)) {
                            DetailHistoryView(workout: selectedWorkout, viewModel: viewModel, themeManager: _themeManager)
                        }
                }
                .listRowInsets(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear) 
            }
            .listStyle(.plain)
            .padding(.horizontal)
            .navigationBarTitle("History", displayMode: .inline)
            .toolbar {
                FilterView(workoutType: $viewModel.filteredType)
                    .scaleEffect(0.6)
            }
            .onChange(of: viewModel.filteredType, perform: { _ in
                viewModel.filterWorkouts()
            })
            .onAppear {
                selectedWorkout = nil
                viewModel.filterWorkouts()
            }
            .overlay(
                viewModel.filteredWorkouts.isEmpty ?
                EmptyResultView(selectedTab: $selectedTab) : nil
            )
        }
        .background(Color(hex: "#F2F2F7"))
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(dataManager: .preview, selectedTab: .constant(0))
    }
}
