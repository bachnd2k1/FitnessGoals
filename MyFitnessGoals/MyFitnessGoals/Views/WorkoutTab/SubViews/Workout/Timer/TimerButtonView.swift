//
//  TimerButtonView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import SwiftUI

struct TimerButtonView: View {
    let label: String
    let color: Color
    let disabled: Bool
    var equalWidth: Bool = false
    let action: () -> ()
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            Text(label)
                .font(.title)
                .foregroundStyle(disabled ? .white : .black)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .frame(maxWidth: equalWidth ?  .infinity : .none)
                .background(disabled ? .gray : color)
                .cornerRadius(10)
//                .frame(maxWidth: equalWidth ?  .infinity : .none)
            
        }
        .padding(.bottom)
        .disabled(disabled)
    }
}


struct TimerButtonView_Previews: PreviewProvider {
    static var previews: some View {
        TimerButtonView(label: L10n.settingBtn, color: .green, disabled: false, equalWidth: true) {}
    }
}
