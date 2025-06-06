//
//  FillInfoView.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 5/6/25.
//

import SwiftUI

struct FillInfoView: View {
    var onNext: () -> Void
    
    @State private var age: Int? = nil
    @State private var showAgePicker = false
    
    @State private var gender: String? = nil
    @State private var showGenderPicker = false
    let genderOptions = ["Male", "Female"]
    
    @State private var weight: Int? = nil
    @State private var showWeightPicker = false
    
    var body: some View {
        VStack(spacing: 24) {
            
            VStack(spacing: 16) {
                Image(uiImage: Asset.icUser.image)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .padding(.top, 32)
                
                VStack(spacing: 12) {
                    infoRow(icon: "calendar", title: "Age", value: age != nil ? "\(age!)" : "Not defined") {
                        showAgePicker = true
                    }
                    
                    infoRow(icon: "person", title: "Gender", value: gender ?? "Not defined") {
                        showGenderPicker = true
                    }
                    
                    infoRow(icon: "scalemass", title: "Weight", value: weight != nil ? "\(weight!) kg" : "Not defined") {
                        showWeightPicker = true
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
            }

            Spacer()

            Button(action: onNext) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding(.top, 20)
        .sheet(isPresented: $showAgePicker) {
            PickerSheet(title: "Select Age", selection: binding(for: $age, defaultValue: 30), range: 10...100)
                .presentationDetents([.fraction(0.33)])
        }
        .sheet(isPresented: $showGenderPicker) {
            GenderPickerSheet(title: "Select Gender", selection: binding(for: $gender, defaultValue: genderOptions.first!), options: genderOptions)
                .presentationDetents([.fraction(0.33)])
        }
        .sheet(isPresented: $showWeightPicker) {
            WeightPickerSheet(title: "Select Weight", selection: binding(for: $weight, defaultValue: 70), range: 10...100)
                .presentationDetents([.fraction(0.33)])
        }
    }

    private func binding<T: Equatable>(
        for source: Binding<T?>,
        defaultValue: T,
        allowedValues: [T]? = nil
    ) -> Binding<T> {
        Binding<T>(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in
                if let allowedValues = allowedValues {
                    if allowedValues.contains(newValue) {
                        source.wrappedValue = newValue
                    }
                } else {
                    source.wrappedValue = newValue
                }
            }
        )
    }

    private func infoRow(icon: String, title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Text(value)
                        .font(.body)
                        .foregroundColor(value == "Not defined" ? .gray : .primary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}


#Preview {
    FillInfoView { }
}
