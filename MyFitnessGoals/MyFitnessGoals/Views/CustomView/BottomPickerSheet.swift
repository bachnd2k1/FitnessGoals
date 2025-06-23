//
//  BottomPickerSheet.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 5/6/25.
//

import SwiftUI

struct BottomPickerSheet<T: Hashable & CustomStringConvertible>: View {
    let title: String
    let options: [T]
    @Binding var selection: T
    @Environment(\.dismiss) private var dismiss

    @State private var internalSelection: T

    init(title: String, options: [T], selection: Binding<T>) {
        self.title = title
        self.options = options
        self._selection = selection
        self._internalSelection = State(initialValue: selection.wrappedValue)
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker(title, selection: $internalSelection) {
                    ForEach(options, id: \.self) { option in
                        Text(option.description).tag(option)
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

