//
//  LiveActivityContent.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 11/3/25.
//

import Foundation
import ActivityKit
import AppIntents

struct LiveActivityPauseIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Handle Live Activity Pause"
    
    func perform() async throws -> some IntentResult {
        print("Live Activity pause!")

        LiveActivityManager.shared.onPauseAction?()
        LiveActivityManager.shared.updateLiveActivity(isPaused: true)

        return .result()
    }
}

struct LiveActivityContinueIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Handle Live Activity Continue"
    
    func perform() async throws -> some IntentResult {
        print("Live Activity continue!")

        LiveActivityManager.shared.onContinueAction?()
        LiveActivityManager.shared.updateLiveActivity(isPaused: false)

        return .result()
    }
}

struct LiveActivityStopIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Handle Live Activity Stop"
    
    func perform() async throws -> some IntentResult {
        print("Live Activity stop!")

        LiveActivityManager.shared.onStopAction?()

        return .result()
    }
}
