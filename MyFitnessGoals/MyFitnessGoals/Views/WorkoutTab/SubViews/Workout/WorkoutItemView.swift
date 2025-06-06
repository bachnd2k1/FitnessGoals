//
//  WorkoutItemView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import SwiftUI

struct WorkoutItemView: View {
    let workoutType: WorkoutType
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack(alignment: .top) {
                Image(workoutType.banner)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                
                HStack {
                    Text(workoutType.name)
                    Image(systemName: workoutType.icon)
                }
                .padding()
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .opacity(0.8)
            }
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

struct WorkoutItemView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutItemView(workoutType: .running) {
            
        }
    }
}
