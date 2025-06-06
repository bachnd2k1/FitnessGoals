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
    
    var formattedWeight: String {
        String(format: "%.1f", weight ?? 0)
    }
    
    var body: some View {
        VStack {
            
            VStack {
                Image(uiImage: Asset.icUser.image)
                    .resizable()
                    .frame(width: 48, height: 48)
                
                VStack() {
                    infoRow(title: "Age", value: age != nil ? "\(age!)" : "Not defined", action: { showAgePicker = true })
                    infoRow(title: "Gender", value: gender ?? "Not defined", action: { showGenderPicker = true })
                    infoRow(title: "Weight", value: weight != nil ? "\(weight!) kg" : "Not defined", action: { showWeightPicker = true })
                }
                .padding(.bottom)
                .padding(.horizontal)
            }
            .padding(.top, 20)
            .background(Color(hex: "#EEEEEE"))
            .cornerRadius(20)
            
            Spacer()
            Button(action: {
                onNext()
            }) {
                Text("Continue")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#007AFF"))
                    .cornerRadius(20)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top, 40)
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
    
    // Hàm tạo Binding<T> từ Binding<T?> với giá trị mặc định
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

    
    private func infoRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                
                Spacer()
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)

            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    FillInfoView { }
}
