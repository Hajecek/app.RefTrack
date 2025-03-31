import SwiftUI

struct HalfTimeView: View {
    @StateObject private var timerManager = MatchTimerManager()
    @State private var timeRemaining: TimeInterval = 900 // 15 minut = 900 sekund
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Pauza")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text(timeString(from: timeRemaining))
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.edgesIgnoringSafeArea(.all))
        .onAppear {
            startTimer()
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct HalfTimeView_Previews: PreviewProvider {
    static var previews: some View {
        HalfTimeView()
    }
} 