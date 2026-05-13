//
//  TabBarView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import SwiftUI

struct TabBarView: View {
    @StateObject var themeManager = ThemeManager()
    @State private var selectedTab = 0
    private let appEnvironment: AppEnvironment

    init(appEnvironment: AppEnvironment) {
        self.appEnvironment = appEnvironment
    }
    
    var body: some View {
        ZStack {
            // Hiển thị màn hình dựa vào tab được chọn
            switch selectedTab {
            case 0: SelectWorkoutTypeView(dataManager: appEnvironment.dataManager, healthKitManager: appEnvironment.healthKitManager)
            case 1: HistoryView(dataManager: appEnvironment.dataManager, selectedTab: $selectedTab)
            case 2: GeneralStatisticView(dataManager: appEnvironment.dataManager)
            case 3: GoalsView(healthKitManager: appEnvironment.healthKitManager, calendarManager: appEnvironment.calendarManager)
            default: SelectWorkoutTypeView(dataManager: appEnvironment.dataManager, healthKitManager: appEnvironment.healthKitManager)
            }
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.bottom, 30)
                    .padding(.horizontal, 30)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(appEnvironment: AppEnvironment(dataManager: .preview))
            .environmentObject(MobileNavigationRouter())
    }
}
