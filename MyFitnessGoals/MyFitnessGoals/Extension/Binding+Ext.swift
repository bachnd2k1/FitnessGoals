//
//  Binding+Ext.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 17/6/25.
//

import Foundation
import SwiftUI

extension Binding {
    func unwrap<T>(default defaultValue: T) -> Binding<T> where Value == T? {
        Binding<T>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}

