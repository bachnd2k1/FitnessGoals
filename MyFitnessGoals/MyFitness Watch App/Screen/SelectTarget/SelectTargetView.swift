//
//  SelectTargetView.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 29/4/25.
//

import SwiftUI

struct SelectTargetView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ForEach(viewModel.targetGoals, id: \.self) { goal in
            HStack {
                Image(systemName: goal.icon)
                    .foregroundColor(Color(goal.color))
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.measureType)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .fontWeight(.bold)

                    
                    Text(goal.targetValue)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .fontWeight(.regular)
                }
                Spacer()
            }
            .padding(8)
            .background(Color.gray)
            .cornerRadius(8)
            .padding(.bottom, 4)
            .onTapGesture {
                if let infoType = goal.infoType {
                    viewModel.updateSelectType(infoType: infoType)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    SelectTargetView(viewModel: HomeViewModel())
}
