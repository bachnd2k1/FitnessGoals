//
//  MeasureItemView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import SwiftUI

struct MeasureItemView: View {
    let measure: MeasureUnit?
    let value: Double?
    let size: CGFloat?

    var body: some View {
        VStack {
            Text(measure?.name ?? "")
            switch measure {
            case .distance:
                Text(distanceFormatter(for: value) ?? "")
            case .speed:
                Text(speedFormatter(for: value) ?? "")
            default:
//                EmptyView()
                Text(speedFormatter(for: value) ?? "")
            }
            Text(measure?.unitOfMeasure ?? "")
        }
        .font(.headline)
        .frame(width: size)
        .padding(2)
        .background(.white.opacity(0.6))
        .cornerRadius(10)
    }
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    private func distanceFormatter(for value: Double?) -> String? {
        // conversion meters -> kilometers
        var replaceValue = value
        if replaceValue ?? 0.0 < 0 { replaceValue = 0 }
        guard let valueInMeters = replaceValue else { return nil }
        return formatter.string(for: (valueInMeters / 1000))
    }

    private func speedFormatter(for value: Double?) -> String? {
        // conversion meters/second -> kilometers/hour
        guard let valueInMetersPerSecond = value else { return nil }
        return formatter.string(for: (valueInMetersPerSecond * 3.6))
    }
}

//struct MeasureItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        MeasureItemView()
//    }
//}
