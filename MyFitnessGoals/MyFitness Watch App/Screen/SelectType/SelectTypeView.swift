//
//  SelectTypeView.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 29/4/25.
//

import SwiftUI
import WatchConnectivity

struct SelectTypeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject private var sessionManager = WatchSessionManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
//            if !sessionManager.isCompanionAppInstalled {
//                Text("Please install the MyFitness app on your iPhone to use this feature")
//                    .font(.system(size: 16))
//                    .multilineTextAlignment(.center)
//                    .padding()
//            } else {
                ForEach(WorkoutType.allCases, id: \.self) { workoutType in
                    HStack {
                        Text(workoutType.name)
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(8)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .padding(.bottom, 4)
                    .onTapGesture {
                        viewModel.updateSelectWorkoutType(workoutType: workoutType)
                        sendMessageToPhone(workoutType: workoutType)
                        dismiss()
                    }
                }
            }
//        }
    }
    
    private func sendMessageToPhone(workoutType: WorkoutType) {
        WatchSessionManager.shared.sendMessageToPhone(
            ["action": "startWorkout", "type": workoutType.rawValue],
            replyHandler: { reply in
                print("Received reply from iPhone: \(reply)")
            },
            errorHandler: { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        )
    }
}

#Preview {
    SelectTypeView(viewModel: HomeViewModel())
}
