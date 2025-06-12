//
//  RequestPermissonView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 09/02/2025.
//

import SwiftUI

struct RequestPermissonView: View {
    @State var isDenied: Bool = false
    @ObservedObject var viewModel: WorkoutViewModel
   
    @EnvironmentObject var router: MobileNavigationRouter
//    @Binding var workoutType: WorkoutType?
    @State private var offset: CGFloat = 0
    var workoutType: WorkoutType
    var permissionInfo: PermissionInfo
    
    //    init(workoutType: Binding<WorkoutType?>, viewModel: WorkoutViewModel) {
    //        self._workoutType = workoutType
    //        _viewModel = .init(wrappedValue: WorkoutViewModel(dataManager: .shared, type: workoutType.wrappedValue, healthKitManager: .shared))
    //    }
    
    init(workoutType: WorkoutType, viewModel: WorkoutViewModel, permissionInfo: PermissionInfo) {
        //        self._workoutType = workoutType
        self.workoutType = workoutType
        self.viewModel = viewModel
        self.workoutType = workoutType
        self.permissionInfo = permissionInfo
//        self.viewModel = WorkoutViewModel(
//            dataManager: .shared,
//            type: workoutType,
//            healthKitManager: .shared
//        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack(alignment: .topLeading) {
                    Image(workoutType.banner)
                        .resizable()
                        .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
                        .ignoresSafeArea(edges: .top)
                        .frame(height: geometry.size.height * 0.7)
                    
                    
                    HStack {
                        Button {
//                            workoutType = nil
                            router.currentWorkoutType = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                                .padding()
                        }
                        Spacer()
                    }
                }
                
                Text(permissionInfo.permissionTitle(state: viewModel.permissionState(for: permissionInfo)))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                
                Text(permissionInfo.permissionMessage(state: viewModel.permissionState(for: permissionInfo)))
                    .font(.system(size: 15))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                
                Button(action: {
                    viewModel.requestPermisson()
                }) {
                    Text(permissionInfo.buttonTitle(state: viewModel.permissionState(for: permissionInfo)))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 6)
                .padding(.bottom, 10)
                
                Spacer()
            }
        }
    }
}

struct RequestPermissonView_Previews: PreviewProvider {
    static var previews: some View {
        RequestPermissonView(workoutType: .running, viewModel: .init(dataManager: .preview, type: nil, healthKitManager: .shared, workoutSessionManager: WorkoutSessionManager()), permissionInfo: .location)
    }
}
