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
    @EnvironmentObject var router: NavigationRouter
//    @Binding var workoutType: WorkoutType?
    @State private var offset: CGFloat = 0
    let workoutType: WorkoutType
    
    //    init(workoutType: Binding<WorkoutType?>, viewModel: WorkoutViewModel) {
    //        self._workoutType = workoutType
    //        _viewModel = .init(wrappedValue: WorkoutViewModel(dataManager: .shared, type: workoutType.wrappedValue, healthKitManager: .shared))
    //    }
    
    init(workoutType: WorkoutType, viewModel: WorkoutViewModel) {
        //        self._workoutType = workoutType
        self.workoutType = workoutType
        self.viewModel = viewModel
        self.viewModel.workoutType = workoutType
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
                
                Text(permissionTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                
                Text(permissionMessage)
                    .font(.system(size: 15))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                
                Button(action: {
                    viewModel.requestPermisson()
                }) {
                    Text(buttonTitle)
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
    
    private var permissionTitle: String {
        viewModel.locationAccessIsDenied && viewModel.locationAccessNotDetermine ? L10n.denyLocationTitle : L10n.requestLocationTitle
    }
    
    private var permissionMessage: String {
        viewModel.locationAccessIsDenied && viewModel.locationAccessNotDetermine  ?
        L10n.denyLocationMessage :
        L10n.requestLocationMessage
    }
    
    private var buttonTitle: String {
        viewModel.locationAccessIsDenied && viewModel.locationAccessNotDetermine  ?
        L10n.denyLocationAction :
        L10n.requestLocationAction
    }
}

struct RequestPermissonView_Previews: PreviewProvider {
    static var previews: some View {
//        RequestPermissonView(workoutType: .constant(.running), viewModel: .init(dataManager: .preview, type: nil, healthKitManager: .shared))
        RequestPermissonView(workoutType: .running, viewModel: .init(dataManager: .preview, type: nil, healthKitManager: .shared))
    }
}
