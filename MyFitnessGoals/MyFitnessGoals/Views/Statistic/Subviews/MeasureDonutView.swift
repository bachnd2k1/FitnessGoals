//
//  MeasureDonutView.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 11/3/25.
//

import SwiftUI

struct MeasureDonutView: View {
    @Environment(\.colorScheme) private var colorScheme
    let measure: Double
    let formattedMeasure: String
    let unitOfMeasure: String
    let icon: String
    let goal: Double
    let height: CGFloat
    let width: CGFloat

    var body: some View {
        Circle()
            .strokeBorder(colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.7), lineWidth: 10)
            .overlay {
                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                    Text(formattedMeasure)
                    Text(unitOfMeasure)
                }
                .font(.title3)
                .fontWeight(.heavy)
                .foregroundStyle(Color.accentColor)
                
            }
            .overlay  {
                MeasureArc(measure: measure, goal: goal)
                    .rotation(Angle(degrees: -90))
                    .stroke(Color.accentColor, lineWidth: 5)
            }
            .frame(width: width ,height: height)
    }
}

#Preview {
    HStack(spacing: 4) {
        MeasureDonutView(measure: 2236,
                         formattedMeasure: "2.236",
                         unitOfMeasure: MeasureUnit.distance.unitOfMeasure,
                         icon: MeasureUnit.distance.icon,
                         goal: 2500,
                         height: 140,
                         width: 130
        )
        MeasureDonutView(measure: 326,
                         formattedMeasure: "326",
                         unitOfMeasure: MeasureUnit.calorie.unitOfMeasure,
                         icon: MeasureUnit.calorie.icon,
                         goal: 350,
                         height: 140,
                         width: 130
        )
        MeasureDonutView(measure: 10350,
                         formattedMeasure: "10 350",
                         unitOfMeasure: MeasureUnit.step.unitOfMeasure,
                         icon: MeasureUnit.step.icon,
                         goal: 10000,
                         height: 140,
                         width: 130
        )
    }
}

struct MeasureArc: Shape {
    let measure: Double
    let goal: Double

    private var degreesPerUnit: Double {
        360.0 / goal
    }
    private var startAngle: Angle {
        Angle(degrees: 0)
    }
    private var endAngle: Angle {
        Angle(degrees: startAngle.degrees + degreesPerUnit * measure)
    }
        
    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.size.width, rect.size.height) - 40
        let radius = diameter / 2.0
        let center = CGPoint(x: rect.midX, y: rect.midY)
        return Path { path in
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
    }
}
