// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Do you want to cancel this workout session ?
  internal static let cancelSessionTitleDialog = L10n.tr("Localizable", "cancel_session_title_dialog", fallback: "Do you want to cancel this workout session ?")
  /// Open Settings
  internal static let denyAction = L10n.tr("Localizable", "deny_action", fallback: "Open Settings")
  /// You have denied location access. Please go to Settings to enable it again!
  internal static let denyLocationMessage = L10n.tr("Localizable", "deny_location_message", fallback: "You have denied location access. Please go to Settings to enable it again!")
  /// Location access denied
  internal static let denyLocationTitle = L10n.tr("Localizable", "deny_location_title", fallback: "Location access denied")
  /// You have denied motion access. Please go to Settings to enable it again!
  internal static let denyMotionMessage = L10n.tr("Localizable", "deny_motion_message", fallback: "You have denied motion access. Please go to Settings to enable it again!")
  /// Motion access denied
  internal static let denyMotionTitle = L10n.tr("Localizable", "deny_motion_title", fallback: "Motion access denied")
  /// Backup your workout data in Apple Health and enable all step counter and heart rate features.
  internal static let descriptionHeathPermisson = L10n.tr("Localizable", "description_heath_permisson", fallback: "Backup your workout data in Apple Health and enable all step counter and heart rate features.")
  /// %@ needs access to your location to record your workouts.
  internal static func descriptionLocationPermisson(_ p1: Any) -> String {
    return L10n.tr("Localizable", "description_location_permisson", String(describing: p1), fallback: "%@ needs access to your location to record your workouts.")
  }
  /// %@ needs access to your motion service to record your workouts.
  internal static func descriptionMotionPermisson(_ p1: Any) -> String {
    return L10n.tr("Localizable", "description_motion_permisson", String(describing: p1), fallback: "%@ needs access to your motion service to record your workouts.")
  }
  /// Duration
  internal static let duration = L10n.tr("Localizable", "duration", fallback: "Duration")
  /// This will stop recording your current workout and save it to your history.
  internal static let endSessionTitleDialog = L10n.tr("Localizable", "end_session_title_dialog", fallback: "This will stop recording your current workout and save it to your history.")
  /// Location Access Error
  internal static let locationError = L10n.tr("Localizable", "location_error", fallback: "Location Access Error")
  /// Please go to your Settings and enable Motion Services to be able to start recording a workout.
  internal static let motionDisableDescription = L10n.tr("Localizable", "motion_disable_description", fallback: "Please go to your Settings and enable Motion Services to be able to start recording a workout.")
  /// Motion Services Disabled
  internal static let motionDisableTitle = L10n.tr("Localizable", "motion_disable_title", fallback: "Motion Services Disabled")
  /// No
  internal static let no = L10n.tr("Localizable", "no", fallback: "No")
  /// No data is available, please check permissions in the Health App - Profile (top right corner) - Privacy - Apps - MyFitNessGoals.
  internal static let noPermissonHealthKit = L10n.tr("Localizable", "no_permisson_health_kit", fallback: "No data is available, please check permissions in the Health App - Profile (top right corner) - Privacy - Apps - MyFitNessGoals.")
  /// ok
  internal static let ok = L10n.tr("Localizable", "ok", fallback: "ok")
  /// Open Health App
  internal static let openHealthApp = L10n.tr("Localizable", "open_health_app", fallback: "Open Health App")
  /// Allow permisson
  internal static let requestAction = L10n.tr("Localizable", "request_action", fallback: "Allow permisson")
  /// To continue, please go to Settings and allow the app to access your location!
  internal static let requestLocationMessage = L10n.tr("Localizable", "request_location_message", fallback: "To continue, please go to Settings and allow the app to access your location!")
  /// Allow location access
  internal static let requestLocationTitle = L10n.tr("Localizable", "request_location_title", fallback: "Allow location access")
  /// To continue, please go to Settings and allow the app to access your motion!
  internal static let requestMotionMessage = L10n.tr("Localizable", "request_motion_message", fallback: "To continue, please go to Settings and allow the app to access your motion!")
  /// Allow motion access
  internal static let requestMotionTitle = L10n.tr("Localizable", "request_motion_title", fallback: "Allow motion access")
  /// Open Setting
  internal static let settingBtn = L10n.tr("Localizable", "setting_btn", fallback: "Open Setting")
  /// Start
  internal static let startBtn = L10n.tr("Localizable", "start_btn", fallback: "Start")
  /// Steps
  internal static let steps = L10n.tr("Localizable", "steps", fallback: "Steps")
  /// My goal
  internal static let titleMyGoal = L10n.tr("Localizable", "title_my_goal", fallback: "My goal")
  /// Localizable.strings
  ///   MyFitnessGoals
  /// 
  ///   Created by Nghiem Dinh Bach on 17/3/25.
  internal static let titleSelectWork = L10n.tr("Localizable", "title_select_work", fallback: "Begin Workout")
  /// Warning !
  internal static let warning = L10n.tr("Localizable", "warning", fallback: "Warning !")
  /// Yes
  internal static let yes = L10n.tr("Localizable", "yes", fallback: "Yes")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
