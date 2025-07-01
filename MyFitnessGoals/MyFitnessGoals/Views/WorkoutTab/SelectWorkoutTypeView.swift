//
//  SelectWorkoutTypeView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import SwiftUI

struct SelectWorkoutTypeView: View {
    @State private var selectedWorkoutType: WorkoutType?
    @StateObject var viewModel: SelectWorkoutViewModel
    @EnvironmentObject var router: MobileNavigationRouter
    let dataManager: CoreDataManager
    let healthKitManager: HealthKitManager
    
    
    init(dataManager: CoreDataManager, healthKitManager: HealthKitManager) {
        self.dataManager = dataManager
        self.healthKitManager = healthKitManager
        self._viewModel = .init(wrappedValue: SelectWorkoutViewModel())
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
                            let workoutViewModel = WorkoutViewModel(
                                dataManager: dataManager,
                                type: workoutType,
                                healthKitManager: healthKitManager,
                                workoutSessionManager: WorkoutSessionManager.shared
                            )
                            if viewModel.locationAccessIsDenied && !workoutViewModel.locationAccessNotDetermine {
                                RequestPermissonView(workoutType: workoutType, viewModel: workoutViewModel, permissionInfo: .location)
                            } else if viewModel.motionAccessIsDenied && !workoutViewModel.motionAccessNotDetermine {
                                RequestPermissonView(workoutType: workoutType, viewModel: workoutViewModel, permissionInfo: .motion)
                            } else {
                                RecordWorkoutView(workoutType: workoutType,viewModel: workoutViewModel)
                            }
                        }
                    }
                }
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
            .environmentObject(MobileNavigationRouter())
    }
}
