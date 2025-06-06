//
//  MetricView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 15/02/2025.
//

import SwiftUI

struct MetricView: View {
    let value: String
    let label: String
    let icon: String
    var color: Color = .primary
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .minimumScaleFactor(0.8) // Cho phép chữ co lại nếu không đủ chỗ
                .lineLimit(1) // Tránh xuống dòng ngoài ý muốn
                .padding(.bottom, 5)
                
            HStack(alignment: .center) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                Text(label)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
        }
        .frame(minWidth: 80, maxWidth: .infinity) 
    }
}

struct MetricView_Previews: PreviewProvider {
    static var previews: some View {
        MetricView(value: "Hello", label: "Bach", icon: "figure.walk")
    }
}
