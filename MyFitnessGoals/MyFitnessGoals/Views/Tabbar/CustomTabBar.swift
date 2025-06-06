//
//  CustomTabBar.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 13/3/25.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                TabBarButton(icon: Constant.Tab.workout.rawValue, title: Constant.Tab.workout.tabName, isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                TabBarButton(icon: Constant.Tab.history.rawValue, title: Constant.Tab.history.tabName, isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                TabBarButton(icon: Constant.Tab.statistics.rawValue, title: Constant.Tab.statistics.tabName, isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                
                TabBarButton(icon: Constant.Tab.goals.rawValue, title: Constant.Tab.goals.tabName, isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
            )
        }
        .frame(maxWidth: .infinity)
    }
}

struct TabBarButton: View {
    var icon: String
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? Color(hex: "#007AFF") : .gray)

                Text(title)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? Color(hex: "#007AFF") : .gray)
            }
            .padding(.horizontal, 10)
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(0))
}
