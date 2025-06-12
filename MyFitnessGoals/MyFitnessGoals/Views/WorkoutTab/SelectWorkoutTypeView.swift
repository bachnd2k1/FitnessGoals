//
//  SelectWorkoutTypeView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import SwiftUI

struct SelectWorkoutTypeView: View {
    @State private var selectedWorkoutType: WorkoutType?
    @StateObject var viewModel: WorkoutViewModel
    @EnvironmentObject var router: MobileNavigationRouter
    let dataManager: CoreDataManager
    
    init(dataManager: CoreDataManager, healthKitManager: HealthKitManager) {
        self.dataManager = dataManager
        self._viewModel = .init(wrappedValue: WorkoutViewModel(dataManager: dataManager, type: nil, healthKitManager: .shared, workoutSessionManager: WorkoutSessionManager.shared))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(WorkoutType.allCases, id: \.self) { workoutType in
                        WorkoutItemView(workoutType: workoutType) {
                            router.openRecordWorkout(type: workoutType)
                        }
                        .fullScreenCover(item: $router.currentWorkoutType) { workoutType in
                            if viewModel.locationAccessIsDenied {
                                RequestPermissonView(workoutType: workoutType, viewModel: viewModel, permissionInfo: .location)
                            } else if viewModel.motionAccessIsDenied {
                                RequestPermissonView(workoutType: workoutType, viewModel: viewModel, permissionInfo: .motion)
                            } else {
                                RecordWorkoutView(workoutType: workoutType,viewModel: viewModel)
                            }
                        }
                    }
                }
            }
            .onAppear {
//                viewModel.requestPermissonHealthKit()
            }
            .padding(.top, 10)
            .navigationBarTitle(L10n.titleSelectWork, displayMode: .inline)
        }
        .background(Color(hex: "#F2F2F7"))
    }
}

struct SelectWorkoutTypeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectWorkoutTypeView(dataManager: .preview, healthKitManager: .shared)
    }
}
