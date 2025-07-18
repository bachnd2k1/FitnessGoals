//
//  RequestPermissionView.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 5/6/25.
//

import SwiftUI

struct RequestPermissionView: View {
    @ObservedObject var viewModel: WelcomeFlowViewModel
    var permission: PermissionInfo
    var onNext: () -> Void

    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 8) {
                HStack {
                    Image(permission.icon)
                        .resizable()
                        .frame(width: 60, height: 60)

                    Text(permission.name)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }

                Text(permission.description)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.top, 8)
            }
            .padding()

            Spacer()

            Button(action: {
                switch permission {
                case .health:
                    viewModel.requestHealthPermisson()
                case .location:
                    viewModel.requestLocationPermisson()
                case .motion:
                    viewModel.requestMotionPermisson()
                }
            }) {
                Text(permission == .motion ? "Finish" : "Continue")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#007AFF"))
                    .cornerRadius(20)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .onChange(of: viewModel.isRequestHealthPermisson) { oldValue, newValue in
            onNext()
        }
        .onChange(of: viewModel.isRequestLocationPermisson) { oldValue, newValue in
            onNext()
        }
        .onChange(of: viewModel.isRequestMotionPermisson) { oldValue, newValue in
            onNext()
        }
    }
}


#Preview {
    RequestPermissionView(viewModel: WelcomeFlowViewModel(healthKitManager: .shared), permission: .health, onNext: {})
}
