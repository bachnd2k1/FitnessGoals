import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager = WatchTimerManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text(timeString)
                .font(.system(size: 60, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
            
            if !timerManager.isRunning {
                Button(action: {
                    timerManager.startTimer()
                }) {
                    Text("Start")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            } else {
                Button(action: {
                    timerManager.stopTimer()
                }) {
                    Text("Stop")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
    
    private var timeString: String {
        let hours = Int(timerManager.elapsedTime) / 3600
        let minutes = Int(timerManager.elapsedTime) / 60 % 60
        let seconds = Int(timerManager.elapsedTime) % 60
        let milliseconds = Int((timerManager.elapsedTime.truncatingRemainder(dividingBy: 1)) * 10)
        
        return String(format: "%02d:%02d:%02d.%d", hours, minutes, seconds, milliseconds)
    }
} 