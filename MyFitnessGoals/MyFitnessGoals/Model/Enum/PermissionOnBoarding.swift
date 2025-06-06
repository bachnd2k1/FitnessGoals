//
//  Permission .swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 5/6/25.
//

import Foundation

enum PermissionOnBoarding: Int16, CaseIterable, Identifiable  {
    var id: Int16 { rawValue }
    
    case health, location, motion
    
    
    var name: String {
        switch self {
        case .health: return "Health"
        case .location: return "Location"
        case .motion: return "Motion"
        }
    }

    var icon: String {
        switch self {
        case .health: return Asset.icHealthkit.name
        case .location: return Asset.icLocation.name
        case .motion: return Asset.icMotion.name
        }
    }
    
    var description: String {
        switch self {
        case .health: return String(format: L10n.descriptionHeathPermisson)
        case .location: return String(format: L10n.descriptionLocationPermisson(AppInfo.appName))
        case .motion: return String(format: L10n.descriptionMotionPermisson(AppInfo.appName))
        }
    }
}

