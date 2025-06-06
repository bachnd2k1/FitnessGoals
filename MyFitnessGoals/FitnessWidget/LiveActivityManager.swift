//
//  LiveActivityManager.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 11/3/25.
//

import Foundation
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var activity: Activity<FitnessAttributes>?
    
    var onStopAction: (() -> Void)?
    var onPauseAction: (() -> Void)?
    var onContinueAction: (() -> Void)?
    
    private init() {}
    
    func updateActivity(time: String, step: Int, distance: String, speed: String, type: String, icon: String, isPaused: Bool) {
        print("Time: \(time) | distance: \(distance)")
        guard let activity = activity else {
            print("❌ Live Activity not started yet")
            let attributes = FitnessAttributes(workoutType: type)
            let contentState = FitnessAttributes.ContentState(
                elapsedTime: time,
                steps: step,
                distance: distance,
                speed: speed,
                icon: icon,
                isPaused: isPaused
            )
            do {
                activity = try Activity.request(
                    attributes: attributes,
                    content: ActivityContent(state: contentState, staleDate: nil),
                    pushType: nil
                )
            } catch {
                print("❌ Failed to start Live Activity: \(error)")
            }
            return
        }
        
        Task {
            await activity.update(
                ActivityContent(state: FitnessAttributes.ContentState(
                    elapsedTime: time,
                    steps: step,
                    distance: distance,
                    speed: speed,
                    icon: icon,
                    isPaused: isPaused
                ), staleDate: nil)
            )
        }
    }
    
    func endActivity() {
        Task {
            guard let activity = Activity<FitnessAttributes>.activities.first else { return }
            let contentState = activity.content.state
            let finalState = FitnessAttributes.ContentState(
                elapsedTime: contentState.elapsedTime,
                steps: contentState.steps,
                distance: contentState.distance,
                speed: contentState.speed,
                icon: contentState.icon,
                isPaused: true // Đánh dấu trạng thái kết thúc
            )

            let finalContent = ActivityContent(state: finalState, staleDate: nil)
            await activity.end(finalContent, dismissalPolicy: .immediate)
            print("🏁 Live Activity ended")
        }
    }
    
    func updateLiveActivity(isPaused: Bool) {
        Task {
            guard let activity = Activity<FitnessAttributes>.activities.first else { return }

            let currentState = activity.content.state  // ✅ Get the current state

            let newState = FitnessAttributes.ContentState(
                elapsedTime: currentState.elapsedTime,
                steps: currentState.steps,
                distance: currentState.distance,
                speed: currentState.speed,
                icon: currentState.icon,
                isPaused: isPaused
            )

            await activity.update(ActivityContent(state: newState, staleDate: nil)) // ✅ Update Live Activity
            print("Update isPaused \(isPaused)")
        }
    }

}
