//
//  ButtonActionView.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 7/5/25.
//

import SwiftUI

struct ButtonActionView: View {
    var icon: String
    var label: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .padding(.horizontal, 12)
                
                Text(label)
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ButtonActionView(icon: "play.fill", label: "Play", action: {})
}
