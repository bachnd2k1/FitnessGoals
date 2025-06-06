//
//  DeniedPermissionView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import SwiftUI

struct DeniedPermissionView: View {
//    let openSettings: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(L10n.motionDisableTitle)
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.accentColor)
            
            Text(L10n.motionDisableDescription)
                .font(.title2)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.black.opacity(0.7))
        .padding()
    }
}


struct DeniedPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        DeniedPermissionView()
    }
}
