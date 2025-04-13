import Foundation
import Combine

class MatchTimerManager: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var overtimeElapsed: TimeInterval = 0
    @Published var isOvertimeRunning: Bool = false
    @Published var isMainTimerStopped: Bool = false
    
    private var timer: Timer?
    private var overtimeTimer: Timer?
    
    func startTimer() {
        guard timer == nil else { return }
        
        // Pokud je první poločas ukončen, nastavíme čas na začátek druhého poločasu
        if elapsedTime >= MatchTimerSettings.shared.firstHalfTimeInSeconds {
            elapsedTime = MatchTimerSettings.shared.firstHalfTimeInSeconds
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.elapsedTime < MatchTimerSettings.shared.firstHalfTimeInSeconds + MatchTimerSettings.shared.secondHalfTimeInSeconds {
                self.elapsedTime += 1
            } else {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isMainTimerStopped = true
    }
    
    func startOvertimeTimer() {
        isOvertimeRunning = true
        stopTimer()
        
        // Spustíme časovač nastavení na globální úrovni
        overtimeTimer?.invalidate() // Pro jistotu
        overtimeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.overtimeElapsed += 1
        }
    }
    
    func stopOvertimeTimer() {
        isOvertimeRunning = false
        overtimeTimer?.invalidate()
        overtimeTimer = nil
        overtimeElapsed = 0
    }
    
    func timeString() -> String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func overtimeTimeString() -> String {
        let minutes = Int(overtimeElapsed) / 60
        let seconds = Int(overtimeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func setElapsedTime(_ time: TimeInterval) {
        elapsedTime = time
    }
} 