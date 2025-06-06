//
//  GoalsView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 04/02/2025.
//

import SwiftUI

struct GoalsView: View {
    @State private var showShareSheet = false
    @State private var imageToShare: UIImage? = nil
    @State private var selectedIndex = 6
    @State private var selectedDate = Date()
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var viewModel: GoalViewModel
    
    private let dateRange: [Date]

    
    init(dataManager: CoreDataManager, healthKitManager: HealthKitManager) {
        self._viewModel = .init(wrappedValue: GoalViewModel(dataManager: dataManager, healthKitManager: healthKitManager))
        let today = Date()
        let calendar = Calendar.current
        self.dateRange = (0..<7).map { calendar.date(byAdding: .day, value: $0 - 6, to: today)! }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    GoalCarouselView(selectedIndex: $selectedIndex, dateRange: dateRange, viewModel: viewModel)
                        .frame(height: max(geometry.size.width - 120, 50))
                    
                    StatSelectionView(viewModel: viewModel)
                        .padding(.top, 4)
                    
                    if !viewModel.isAuthorized {
                        HealthKitPermissionView()
                            .padding(.top, 30)
                            .padding(.bottom, 20)
                            .padding(.horizontal)
                    } else {
                        ChartDataKitView(data: $viewModel.chartKitData, selectedIndex: $selectedIndex, maxHeight: .constant(geometry.size.height / 3 - 20))
                            .padding(.bottom, 20)
                            .onAppear {
                                viewModel.updateSelectType(infoType: .distance)
                            }
                    }
                    
                    Spacer()
                }
                .padding(.top, 16)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .navigationBarTitle(L10n.titleMyGoal, displayMode: .inline)
                .toolbar {
                    ToolbarShareButton(imageToShare: $imageToShare, showShareSheet: $showShareSheet)
                }
                .sheet(isPresented: $showShareSheet) {
                    if let image = imageToShare {
                        ShareSheet(activityItems: [image])
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        viewModel.checkAuthorizationStatus()
                    }
                }
            }
            .background(Color(hex: "#F2F2F7"))
        }
    }
}

struct GoalCarouselView: View {
    @Binding var selectedIndex: Int
    let dateRange: [Date]
    @ObservedObject var viewModel: GoalViewModel
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(dateRange.indices, id: \.self) { index in
                let date = dateRange[index]
                NavigationLink(destination: SetGoalsView()) {
                    GoalCircleView(date: date, index: index, viewModel: viewModel)
                        .onAppear {
                            viewModel.selectedGoalIndex = index
                        }
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

struct GoalCircleView: View {
    let date: Date
    let index: Int
    
    @ObservedObject var viewModel: GoalViewModel
    
    var body: some View {
        ZStack {
            if let targetGoal = viewModel.targetGoal {
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundColor(Color.gray.opacity(0.2))
                
                VStack {
                    Image(systemName: targetGoal.icon)
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    Text(viewModel.getSelectedHealthKitValue(indexPageDay: index))
                        .font(.largeTitle)
                        .bold()
                    
                    Text(formattedDate(date))
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Goal: " + targetGoal.targetValue + " " + targetGoal.unitOfMeasure + " ▼")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: date)
        
        if today == selected {
            return "Today"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Displays the day name (e.g., Tuesday, Wednesday)
            return formatter.string(from: date)
        }
    }
}

struct StatSelectionView: View {
    @ObservedObject var viewModel: GoalViewModel
    
    var body: some View {
        HStack {
            StatView(icon: "location", unit: "km", color: .brown, isSelected: viewModel.infoType == .distance, viewModel: viewModel) {
                viewModel.updateSelectType(infoType: .distance)
            }
            .frame(maxWidth: .infinity)
            
            StatView(icon: "figure.walk", unit: "Steps", color: .green, isSelected: viewModel.infoType == .step, viewModel: viewModel) {
                viewModel.updateSelectType(infoType: .step)
            }
            .frame(maxWidth: .infinity)
            
            StatView(icon: "flame", unit: "Calories", color: .blue, isSelected: viewModel.infoType == .calories, viewModel: viewModel) {
                viewModel.updateSelectType(infoType: .calories)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .onAppear {
            viewModel.selectTargetGoal(infoType: .distance)
        }
    }
}

struct HealthKitPermissionView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(uiImage: Asset.icHealthkit.image)
                    .resizable()
                    .frame(width: 70, height: 50)
                Image("ic_right_arrow")
                    .resizable()
                    .frame(width: 50, height: 30)
                Image(uiImage: Asset.iconApp.image)
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            Text(L10n.noPermissonHealthKit)
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: "#a9a9a9"))
            
            Button(action: {
                if let url = URL(string: "x-apple-health://") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text(L10n.openHealthApp)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color(hex: "#007AFF"))
                    .cornerRadius(25)
            }
        }
    }
}

struct ToolbarShareButton: View {
    @Binding var imageToShare: UIImage?
    @Binding var showShareSheet: Bool
    
    var body: some View {
        Button {
            withAnimation {
                if let image = captureViewAsImage() {
                    imageToShare = image
                    showShareSheet = true
                }
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(.title2)
                .scaleEffect(0.8)
        }
    }
    
    private func captureViewAsImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: UIScreen.main.bounds.size)
        
        return renderer.image { context in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }
        }
    }

}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView(dataManager: .shared, healthKitManager: .shared)
    }
}
