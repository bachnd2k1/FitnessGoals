//
//  SwipeButtonView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 21/01/2025.
//

import SwiftUI

import SwiftUI

struct SwipeButtonView: View {
    @State private var offset: CGSize = .zero
    @State private var isPressed: Bool = false

    var body: some View {
        VStack {
            Text("Swipe the button")
                .font(.headline)
                .padding()

            Rectangle()
                .fill(Color.blue)
                .frame(width: 200, height: 50)
                .cornerRadius(10)
                .overlay(
                    Text(isPressed ? "Action Triggered!" : "Swipe Me")
                        .foregroundColor(.white)
                        .font(.headline)
                )
                .offset(x: offset.width)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Update the offset based on the drag gesture
                            self.offset.width = value.translation.width
                        }
                        .onEnded { value in
                            // Perform action if swiped enough to the right
                            if value.translation.width > 100 {
                                self.isPressed = true
                                performAction()
                            }
                            // Reset the offset
                            withAnimation {
                                self.offset = .zero
                            }
                        }
                )
                .animation(.easeInOut, value: offset) // Animate the button movement
        }
        .padding()
    }

    private func performAction() {
        // Action to perform when the button is swiped
        print("Action performed!")
        // You can add additional logic here, such as showing an alert or updating state
    }
}

struct SwipeButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeButtonView()
    }
}

