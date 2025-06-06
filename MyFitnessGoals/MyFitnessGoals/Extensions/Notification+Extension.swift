import Foundation

extension Notification.Name {
    static let workoutDidStart = Notification.Name("workoutDidStart")
    static let workoutDidPause = Notification.Name("workoutDidPause")
    static let workoutDidResume = Notification.Name("workoutDidResume")
    static let workoutDidEnd = Notification.Name("workoutDidEnd")
    static let workoutDidUpdateMetrics = Notification.Name("workoutDidUpdateMetrics")
    static let workoutDidCancel = Notification.Name("workoutDidCancel")
} 