//
//  WelcomeView.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 5/6/25.
//

import SwiftUI

struct WelcomeView: View {
    var onNext: () -> Void
    

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(Color(hex: "#007AFF"))
                    
                    Text("Welcome to Goals!")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .bold()
                        .foregroundColor(.primary)
                }
                
                Text("Set Goals. Track Runs & Walks.\nCount Steps.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.top, 8)
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                onNext()
            }) {
                Text("Continue")
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
    }
}

#Preview {
    WelcomeView {}
}
