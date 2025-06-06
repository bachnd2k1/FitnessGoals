//
//  GenderPickerSheet.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 5/6/25.
//

import SwiftUI

struct GenderPickerSheet: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    @Environment(\.dismiss) private var dismiss
    
    @State private var internalSelection: String
    
    init(title: String, selection: Binding<String>, options: [String]) {
        self.title = title
        self._selection = selection
        self.options = options
        _internalSelection = State(initialValue: selection.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(title, selection: $internalSelection) {
                    ForEach(options, id: \.self) { value in
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

