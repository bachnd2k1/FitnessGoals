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
    var dataManager: CoreDataManager
    @EnvironmentObject var router: NavigationRouter

    init(dataManager: CoreDataManager) {
        self.dataManager = dataManager
    }
    
    var body: some View {
        ZStack {
            // Hiển thị màn hình dựa vào tab được chọn
            switch selectedTab {
            case 0: SelectWorkoutTypeView(dataManager: .shared, healthKitManager: .shared)
            case 1: HistoryView(dataManager: .shared, selectedTab: $selectedTab)
            case 2: GeneralStatisticView(dataManager: .shared)
            case 3: GoalsView(dataManager: .shared, healthKitManager: .shared)
            default: SelectWorkoutTypeView(dataManager: .shared, healthKitManager: .shared)
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
        TabBarView(dataManager: .preview)
    }
}
