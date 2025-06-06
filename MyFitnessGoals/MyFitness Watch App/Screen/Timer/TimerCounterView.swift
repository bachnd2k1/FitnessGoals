import SwiftUI

struct TimerCounterView: View {
    @StateObject private var timerManager = WatchTimerManager.shared
    
    var body: some View {
        VStack {
            Text(timeString)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            if !timerManager.isRunning {
                Button("Start") {
                    timerManager.startTimer()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Stop") {
                    timerManager.stopTimer()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
    }
    
    private var timeString: String {
        let hours = Int(timerManager.elapsedTime) / 3600
        let minutes = Int(timerManager.elapsedTime) / 60 % 60
        let seconds = Int(timerManager.elapsedTime) % 60
        let milliseconds = Int((timerManager.elapsedTime.truncatingRemainder(dividingBy: 1)) * 10)
        
        return String(format: "%02d:%02d:%02d.%d", hours, minutes, seconds, milliseconds)
    }
} 
