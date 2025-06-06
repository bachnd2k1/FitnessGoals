//
//  PermissionState.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 6/6/25.
//

import Foundation

struct PermissionState {
    var isDenied: Bool
    var isNotDetermined: Bool
    
    var isDeniedState: Bool {
        isDenied && isNotDetermined
    }
}

