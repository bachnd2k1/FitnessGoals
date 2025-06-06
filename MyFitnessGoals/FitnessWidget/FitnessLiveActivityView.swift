//
//  FitnessLiveActivityView.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 11/3/25.
//

import SwiftUI
import ActivityKit
import WidgetKit

struct FitnessLiveActivityView: View {
    let context: ActivityViewContext<FitnessAttributes>

    var body: some View {
        VStack() {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.gray)
                Text(context.state.elapsedTime)
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: context.state.icon)
                    .foregroundColor(.gray)
                Text(context.attributes.workoutType)
                    .foregroundColor(.black)
            }
            .font(.headline)
            .foregroundColor(.white)
            
            HStack {
                VStack(alignment: .leading) {
                    HStack(spacing: 8) {
                        Image(systemName: "speedometer")
                            .foregroundColor(.green)
                            .frame(width: 14, height: 14)
                        Text("\(context.state.speed) km/h")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                    }
                    .padding(.bottom, 2)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.brown)
                            .frame(width: 14, height: 14)
                        Text("\(context.state.distance) km")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                    }
                }
                .padding(.leading, 4)
                Spacer()
                HStack() {
                    if context.state.isPaused {
                        Button(intent: LiveActivityPauseIntent()) {
                            Image(systemName: "pause.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        
                    } else {
                        HStack(spacing: 4) {
                            Button(intent: LiveActivityStopIntent()) {
                                Image(systemName: "stop.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            
                            Button(intent: LiveActivityContinueIntent()) {
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.trailing, 4)
            }
            .padding(.top, 2)
        }
        .padding(12)
    }
}



