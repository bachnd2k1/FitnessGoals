//
//  EmptyView.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 12/3/25.
//

import Foundation
import SwiftUI

struct EmptyResultView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            VStack {
                Spacer()
                Image("ic_no_results")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.6, height: 200)
                    .clipped()
                
                Text("Result Not Found")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                
                Button {
                    selectedTab = 0
                } label: {
                    Text("Go back")
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                        .cornerRadius(8)
                }
                Spacer()
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
    }
}


struct EmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyResultView(selectedTab: .constant(0))
    }
}
