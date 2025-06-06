//
//  TimerManager.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation
import Combine

@MainActor
class TimerManager: ObservableObject {
    var timer: Timer.TimerPublisher?
    @Published var state: TimerMode?
    @Published var elapsedTime: TimeInterval = 0
    @Published var isNil: Bool = true
    private var cancellable: AnyCancellable?
    

    private func setTimer(from date: Date) {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
        cancellable = timer?
                .autoconnect()
                .map { $0.timeIntervalSince(date) }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] time in
                    self?.elapsedTime = time
                }
    }
    
    func start() {
        state = .counting
        isNil = false
        setTimer(from: Date())
    }
    
    func pause() {
        state = .paused
        isNil = false
        cancellable?.cancel()
    }
    
    func resume() {
        state = .resuming
        isNil = false
        setTimer(from: Date() - elapsedTime)
    }
    
    func stop() {
        cancellable?.cancel()
        isNil = true
        elapsedTime = 0
    }
}

enum TimerMode {
    case counting
    case paused
    case resuming
}
