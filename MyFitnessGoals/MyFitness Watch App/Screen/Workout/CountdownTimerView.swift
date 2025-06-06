//
//  CountdownTimerView.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 7/5/25.
//

import SwiftUI

struct CountdownTimerView: View {
    var count: Int
    let totalCount: Int
    var showCountdownView: Bool
    
    // Lấy chiều rộng màn hình để tự scale
    var screenWidth: CGFloat {
#if os(watchOS)
        return WKInterfaceDevice.current().screenBounds.width
#else
        return UIScreen.main.bounds.width
#endif
    }
    
    var body: some View {
        let circleSize = screenWidth * 0.8  // 60% chiều rộng màn hình
        let lineWidth = screenWidth * 0.08  // 8% chiều rộng
        let fontSize = screenWidth * 0.2    // 20% chiều rộng
        
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundColor(Color(hex: "#007AFF"))
            
            Circle()
                .trim(from: 0.0, to: CGFloat(count) / CGFloat(totalCount))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color(hex: "#007AFF"))
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: count)
            
            if showCountdownView {
                Text("\(count)")
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundStyle(Color(hex: "#333333"))
                    
            } else {
                Text("Goal")
                    .font(.system(size: fontSize * 0.75, weight: .bold))
                    .foregroundStyle(Color(hex: "#333333"))
            }
        }
        .frame(width: circleSize, height: circleSize)
    }
}


#Preview {
    //    CountdownTimerView(count: .constant(4), totalCount: 5)
    CountdownTimerView(count: 4, totalCount: 5, showCountdownView: true)
}


