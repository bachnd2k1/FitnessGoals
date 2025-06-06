//
//  FilterView.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 11/3/25.
//

import Foundation
import SwiftUI

struct FilterView: View {
    @Binding var workoutType: FilteredType
    
    var body: some View {
        Menu {
            Section("Filter By Activity") {
                ForEach(FilteredType.allCases, id: \.self) { type in
                    Button {
                        workoutType = type
                    } label: {
                        Text(type.rawValue.capitalized)
                        if self.workoutType == type {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.title)
        }
    }
}
