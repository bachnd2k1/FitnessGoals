//
//  WatchMetricView.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 6/5/25.
//

import SwiftUI

struct WatchMetricView: View {
    let value: String
    let label: String
    let icon: String
    var color: Color = .primary

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .bold()
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)

            Text(label)
                .font(.caption2)
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(8)
//        .background(Color.blue.opacity(0.6))
        .cornerRadius(10)
    }
}


#Preview {
    WatchMetricView(value: "Hello", label: "Bach", icon: "figure.walk")
}
