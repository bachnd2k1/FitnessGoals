//
//  StatView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 04/02/2025.
//

import SwiftUI

struct StatView: View {
    let icon: String
    let unit: String
    let color: Color
    var isSelected: Bool
    var viewModel: GoalViewModel
    var onClick: () -> Void
    
    @State private var viewWidth: CGFloat = 0
    
    var body: some View {
        VStack() {
            Text(isSelected ? viewModel.percentageValue : "0%")
                .font(.system(size: 16, weight: .bold))
                .fontWeight(.semibold)
            
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            viewWidth = geometry.size.width
                        }
                }
            )
            Rectangle()
                .frame(width: viewWidth * 1.5, height: 2)
                .foregroundColor(.black)
                .opacity(isSelected ? 1 : 0)
                .padding(.top, 1)
        }
        .onTapGesture {
            onClick()
        }
    }
}

struct StatView_Previews: PreviewProvider {
    static var previews: some View {
        StatView(icon: "mappin.and.ellipse", unit: "km", color: .brown, isSelected: true, viewModel: GoalViewModel(dataManager: .shared, healthKitManager: .shared)) {
            
        }
    }
}
