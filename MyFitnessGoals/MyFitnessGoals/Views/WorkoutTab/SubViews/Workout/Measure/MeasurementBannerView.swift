//
//  MeasurementBannerView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import SwiftUI

struct MeasurementBannerView: View {
    let distance: Distance?
    let speed: Speed?
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width / 2.5
            VStack {
                HStack {
                    Spacer()
                    MeasureItemView(measure: distance?.type,
                                    value: distance?.measure.value,
                                    size: size)
                    Spacer()
                    MeasureItemView(measure: speed?.type,
                                    value: speed?.measure.value,
                                    size: size)
                    Spacer()
                }
            }
        }
        .padding(.vertical)
        .frame(height: 100)
        .background(.black.opacity(0.7))
    }
}

//struct MeasurementBannerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MeasurementBannerView()
//    }
//}
