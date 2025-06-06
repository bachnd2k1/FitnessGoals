//
//  ContentView.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 18/4/25.
//

import SwiftUI

//struct HomeView: View {
//    
//    @ObservedObject var viewModel: HomeViewModel
//    
//    init(viewModel: HomeViewModel) {
//        self.viewModel = viewModel
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                NavigationLink(destination: PageView(viewModel: RecordWorkViewModel(dataManager: .shared, type: viewModel.workoutType, healthKitManager: .shared))) {
//                    VStack(alignment: .center, spacing: 16) {
//                        Text(viewModel.workoutType.name)
//                            .font(.system(size: 18))
//                            .fontWeight(.bold)
//                            .padding(.horizontal, 16)
//                            .multilineTextAlignment(.center)
//                        
//                        if let target = viewModel.targetGoal {
//                            Text(target.targetValue)
//                                .font(.system(size: 16))
//                                .fontWeight(.regular)
//                                .padding(.horizontal, 16)
//                                .multilineTextAlignment(.center)
//                        }
//                        
//                        Image(systemName: "play.fill")
//                            .imageScale(.large)
//                            .padding(.top, 4)
//                            .padding(.horizontal, 16)
//                            .foregroundColor(.green)
//                    }
//                    .padding(.vertical, 12)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .background(Color.gray.opacity(0.2))
//                    .cornerRadius(20)
//                }
//                .buttonStyle(PlainButtonStyle())
//                
//                Spacer()
//                
//                HStack(spacing: 24) {
//                    NavigationLink(destination: SelectTypeView(viewModel: viewModel)) {
//                        Image(systemName: "figure.run")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 30, height: 30)
//                            .foregroundColor(.green)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                    
//                    NavigationLink(destination: SelectTargetView(viewModel: viewModel)) {
//                        Image(systemName: "target")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 30, height: 30)
//                            .foregroundColor(.blue)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                    
//                    Image(systemName: "chart.line.uptrend.xyaxis")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(.yellow)
//                }
//                .padding(.vertical, 16)
//                
//            }
//            .padding()
//        }
//    }
//}

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink {
                    // Đây là closure destination, chỉ tạo khi nhấn
                    PageView(viewModel: RecordWorkViewModel(
                        dataManager: .shared,
                        type: viewModel.workoutType,
                        healthKitManager: .shared)
                    )
                } label: {
                    VStack(alignment: .center, spacing: 16) {
                        Text(viewModel.workoutType.name)
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .multilineTextAlignment(.center)
                        
                        if let target = viewModel.targetGoal {
                            Text(target.targetValue)
                                .font(.system(size: 16))
                                .fontWeight(.regular)
                                .padding(.horizontal, 16)
                                .multilineTextAlignment(.center)
                        }
                        
                        Image(systemName: "play.fill")
                            .imageScale(.large)
                            .padding(.top, 4)
                            .padding(.horizontal, 16)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                HStack(spacing: 24) {
                    NavigationLink(destination: SelectTypeView(viewModel: viewModel)) {
                        Image(systemName: "figure.run")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.green)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: SelectTargetView(viewModel: viewModel)) {
                        Image(systemName: "target")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.yellow)
                }
                .padding(.vertical, 16)
                
            }
            .padding()
        }
    }
}


#Preview {
    HomeView(viewModel: HomeViewModel())
}
