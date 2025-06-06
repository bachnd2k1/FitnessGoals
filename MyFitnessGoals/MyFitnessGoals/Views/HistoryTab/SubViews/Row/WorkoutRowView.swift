//
//  WorkoutRowView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 24/01/2025.
//

import SwiftUI

struct WorkoutRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: HistoryViewModel
    let workout: Workout
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.3) : .black.opacity(0.7))
            HStack(spacing: 5) {
                VStack(spacing: 5) {
                    WorkoutDateAndTypeView(workout: workout)
                    WorkoutInfoView(workout: workout, isDisplayAll: false, viewModel: viewModel)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .font(.title3)
            .foregroundStyle(.white)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                withAnimation {
                    viewModel.delete(workout)
                }
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
        }
    }
}

//struct WorkoutRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkoutRowView(viewModel: HistoryViewModel(dataManager: .preview), workout: W)
//    }
//}
