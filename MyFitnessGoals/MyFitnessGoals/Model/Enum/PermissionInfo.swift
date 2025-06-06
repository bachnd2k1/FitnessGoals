//
//  Permission .swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 5/6/25.
//

import Foundation

enum PermissionInfo: Int16, CaseIterable, Identifiable  {
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
    
    func permissionTitle(state: PermissionState) -> String {
        switch self {
        case .location:
            return state.isDeniedState ? L10n.denyLocationTitle : L10n.requestLocationTitle
        case .motion:
            return state.isDeniedState ? L10n.denyMotionTitle : L10n.requestMotionTitle
        default:
            return ""
        }
    }
    
    func permissionMessage(state: PermissionState) -> String {
        switch self {
        case .location:
            return state.isDeniedState ? L10n.denyLocationMessage : L10n.requestLocationMessage
        case .motion:
            return state.isDeniedState ? L10n.denyMotionMessage : L10n.requestMotionMessage
        default:
            return ""
        }
    }
    
    func buttonTitle(state: PermissionState) -> String {
        switch self {
        case .location:
            return state.isDeniedState ? L10n.denyAction : L10n.requestAction
        case .motion:
            return state.isDeniedState ? L10n.denyAction : L10n.requestAction
        default:
            return ""
        }
    }
}


extension PermissionInfo {
    @MainActor func state(from viewModel: WorkoutViewModel) -> PermissionState {
        switch self {
        case .location:
            return PermissionState(
                isDenied: viewModel.locationAccessIsDenied,
                isNotDetermined: viewModel.locationAccessNotDetermine
            )
        case .motion:
            return PermissionState(
                isDenied: viewModel.motionAccessIsDenied,
                isNotDetermined: viewModel.motionAccessNotDetermine
            )
        case .health:
            return PermissionState(
                isDenied: false,
                isNotDetermined: false
            )
        }
    }
}
