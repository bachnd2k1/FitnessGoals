//
//  ChartDataKitView.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 21/3/25.
//

import SwiftUI
import Charts

struct ChartDataKitView: View {
    @Binding var data: [ChartDataKit]
    @Binding var selectedIndex: Int
    @Binding var maxHeight: CGFloat

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let maxHeight: CGFloat = maxHeight
                let maxValue = data.map { CGFloat(Double($0.value) ?? 0) }.max() ?? 1

                HStack(alignment: .bottom, spacing: 16) {
                    Spacer()
                    ForEach(data.indices, id: \.self) { index in
                        let item = data[index]
                        let itemValue = Double(item.value) ?? 0
                        let safeMaxValue = max(maxValue, 1) // Prevents division by zero
                        let barHeight = max(0, min((itemValue / safeMaxValue) * maxHeight, maxHeight))
                        
                        VStack {
                            Text(item.value)
                                .font(.system(size: 8))
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)

                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedIndex == index ? Color.green.opacity(1.0) : Color.green.opacity(0.7))
                                .frame(width: 30, height: barHeight)
                                .onTapGesture {
                                    selectedIndex = (selectedIndex == index) ? -1 : index // Ensure `selectedIndex` is an Int
                                }

                            Text(item.day)
                                .font(.system(size: 8))
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
                .frame(height: maxHeight + 50)
                .padding(.horizontal)
            }
        }
    }
}


#Preview {
    let data = [
        ChartDataKit(day: "Sat", value: "4935"),
        ChartDataKit(day: "Sun", value: "3959"),
        ChartDataKit(day: "Mon", value: "7815"),
        ChartDataKit(day: "Tue", value: "5483"),
        ChartDataKit(day: "Wed", value: "7213"),
        ChartDataKit(day: "Thu", value: "5066"),
        ChartDataKit(day: "Fri", value: "748")
    ]
    ChartDataKitView(data: .constant(data), selectedIndex: .constant(6), maxHeight: .constant(200.0))
}
