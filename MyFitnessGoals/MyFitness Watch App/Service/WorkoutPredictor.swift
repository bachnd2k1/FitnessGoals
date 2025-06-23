//
//  WorkoutPredictor.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 9/6/25.
//

import Foundation

final class WorkoutPredictor {
    private(set) var state = WorkoutState()
    private var lastUpdate: Date?
    private var lastAccel: Double = 0.0
    
    func setWorkoutType(type: WorkoutType) {
        state.workoutType = type
    }
    
    func correct(with measurement: WorkoutMeasurement) {
        state.distance = measurement.distance
        state.speed = measurement.speed
        state.steps = measurement.steps
        state.calories = measurement.calories
        lastUpdate = Date(timeIntervalSince1970: measurement.timestamp)
    }
    
    func predict(accel: Double) {
        guard let lastUpdate = lastUpdate else {
            return
        }
        let dt = Date().timeIntervalSince(lastUpdate)
        if dt > 5.0 { return } // không dự đoán nếu đã quá lâu không nhận data
        
        
        let accelDelta = abs(accel - lastAccel)
        lastAccel = accel

        let movementComponent = accel - 1.0
        let lowAccelThreshold = 0.02

        var accelerationFactor: Double = 0

        if accel < 0.02 && state.speed <= 0.05 {
            // Hoàn toàn đứng yên
            state.speed = 0
        } else if accelDelta < lowAccelThreshold {
            // Chuyển động đều -> không thay đổi tốc độ
            accelerationFactor = 0
        } else if movementComponent > 0 {
            // Đang tăng tốc
            accelerationFactor = movementComponent * 1.5
        } else {
            // Đang giảm tốc
            accelerationFactor = movementComponent * 1.0 // nhỏ hơn khi giảm
        }

        state.acceleration = accelerationFactor
        state.speed = max(0.0, state.speed + accelerationFactor * dt)
        state.distance += state.speed * dt
        predictStep(steps: state.steps)
        
        predictCalories()
        self.lastUpdate = Date()
    }
    
    func predictStep(steps: Int) {
        if  steps > 0 {
            state.steps = steps
        } else {
            // 1 bước ~ 0.8 m -> số bước = distance / 0.8
            // Fallback: dùng distance để đoán
            state.steps = Int(state.distance / 0.8)
        }
    }
    
    func predictCalories() {
        let age = UserDefaults.standard.getInt(for: .weight) ?? 30
        let gender = UserDefaults.standard.getString(for: .gender) ?? "Male"
        let weight = UserDefaults.standard.getInt(for: .weight) ?? 70
        let height = UserDefaults.standard.getInt(for: .height) ?? 150
        let distance = state.distance
        let speed = state.speed
        
        // BMR (Basal Metabolic Rate) là tỷ lệ trao đổi chất cơ bản của cơ thể
        // CT tính calories: Calories = (BMR / 24) × MET × duration (giờ)
        
        // CT BMR theo Mifflin–St Jeor Equation:
        // Nữ giới: BMR = 10 × weight (kg) + 6.25 × height (cm) – 5 × age – 161
        // Nam giới: 10 × weight (kg) + 6.25 × height (cm) – 5 × age + 5
        
        let met: Double
        switch state.workoutType {
        case .running:
            met = 9.8
        case .walking:
            met = 3.8
        case .cycling:
            met = 6.8
        }
        
        let duration = distance / speed
        
        // Tính BMR
        let bmr: Double
        
        if gender == "Male" {
            bmr = 10.0 * Double(weight) + 6.25 * Double(height) - 5.0 * Double(age) + 5
        } else {
            bmr = 10.0 * Double(weight) + 6.25 * Double(height) - 5.0 * Double(age) - 161
        }
        
        // Calories tiêu hao
        let caloriesBurned = (bmr / 24.0) * met * duration
        state.calories = Int(caloriesBurned)
        
        
        //        switch state.workoutType {
        //        case .running:
        //            state.calories = Int(state.distance / 1000 * 70)
        //        case .walking:
        //            state.calories = Int(state.distance / 1000 * 55)
        //        case .cycling:
        //            state.calories = Int(state.distance / 1000 * 25)
        //        }
    }
}
