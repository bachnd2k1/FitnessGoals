//
//  PickerSheet.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 5/6/25.
//

import SwiftUI

struct PickerSheet: View {
    let title: String
    @Binding var selection: Int
    let range: ClosedRange<Int>
    @Environment(\.dismiss) private var dismiss
    
    @State private var internalSelection: Int
    
    init(title: String, selection: Binding<Int>, range: ClosedRange<Int>) {
        self.title = title
        self._selection = selection
        self.range = range
        _internalSelection = State(initialValue: selection.wrappedValue)
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker(title, selection: $internalSelection) {
                    ForEach(range, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
                .frame(height: 200)

                Spacer()
            }
            .navigationBarTitle(Text(title), displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                selection = internalSelection
                dismiss()
            })
        }
    }
}


