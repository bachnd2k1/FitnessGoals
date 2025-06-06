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
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(Color(hex: "#007AFF"))
                    
                    Text("Welcome to Goals!")
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)
                }
                
                Text("Set Goals. Track Runs & Walks.\nCount Steps.")
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .foregroundColor(.primary)
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
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
        }
    }
}

#Preview {
    WelcomeView {}
}
