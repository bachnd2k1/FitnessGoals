//
//  TargetGoal.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 04/02/2025.
//

import Foundation
import UIKit

class TargetGoal: Hashable {
    let measureType: String
    let targetValue: String
    let unitOfMeasure: String
    let icon: String
    let color: UIColor
    var measureValue: String?
    var infoType: InfoType?
    
    init(measureType: String, targetValue: String, unitOfMeasure: String, icon: String, color: UIColor, measureValue: String? = nil, infoType: InfoType? = nil) {
        self.measureType = measureType
        self.targetValue = targetValue
        self.unitOfMeasure = unitOfMeasure
        self.icon = icon
        self.color = color
        self.measureValue = measureValue
        self.infoType = infoType
    }
    
    func logValues() {
            print("""
            Measure Type: \(measureType)
            Target Value: \(targetValue) \(unitOfMeasure)
            Icon: \(icon)
            Color: \(color)
            Measure Value: \(measureValue ?? "N/A")
            """)
        }
    
    static func == (lhs: TargetGoal, rhs: TargetGoal) -> Bool {
        return lhs.measureType == rhs.measureType
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(measureType)
    }
}


