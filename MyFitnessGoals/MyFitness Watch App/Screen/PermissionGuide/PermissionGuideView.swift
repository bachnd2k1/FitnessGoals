//
//  PermissionGuideView.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 11/6/25.
//

import SwiftUI

struct PermissionGuideView: View {
    let permissionInfo: PermissionInfo
    var body: some View {
        VStack() {
            Image(permissionInfo.icon)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.green)
            
            Text(permissionInfo.guideText)
            .font(.footnote)
            .fontWeight(.semibold)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    PermissionGuideView(permissionInfo: .location)
}
