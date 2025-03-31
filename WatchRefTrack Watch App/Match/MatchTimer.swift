import SwiftUI

struct MatchTimer: View {
    let matchId: Int
    
    public init(matchId: Int) {
        self.matchId = matchId
    }
    
    @StateObject private var timerManager = MatchTimerManager()
    @State private var showOvertimeTimer = false
    @State private var overtimeElapsed: TimeInterval = 0
    private var overtimeTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var showEndHalfAlert = false
    @State private var isFirstHalf = true
    @State private var showHalfTimeView = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Hlavní časovač s měnícím se pozadím
                Text(timerManager.timeString())
                    .font(.system(size: 56, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(showOvertimeTimer ? Color.green.opacity(0.2) : Color.white.opacity(0.1))
                            .animation(.easeInOut(duration: 0.5), value: showOvertimeTimer)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                // Dodatečný časovač nastavení
                if showOvertimeTimer {
                    Text("+ \(timeString(from: overtimeElapsed))")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2))
                        )
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(10)
            .onTapGesture {
                showEndHalfAlert = true
            }
            .alert(isFirstHalf ? "Ukončit 1. poločas?" : "Ukončit 2. poločas?", isPresented: $showEndHalfAlert) {
                Button("OK", role: .destructive) {
                    let totalTime = round(timerManager.elapsedTime + overtimeElapsed)
                    
                    // Vypíšeme čas aktuálního poločasu
                    if isFirstHalf {
                        print("Zápas ID: \(matchId), 1. poločas: \(totalTime) sekund")
                    } else {
                        print("Zápas ID: \(matchId), 2. poločas: \(totalTime) sekund")
                    }
                    
                    // Resetujeme a skryjeme časovač nastavení
                    overtimeElapsed = 0
                    showOvertimeTimer = false
                    
                    if isFirstHalf {
                        showHalfTimeView = true
                    }
                    isFirstHalf = false
                }
                Button("Zrušit", role: .cancel) {}
            }
            
            // NavigationLink je nyní v ZStacku, ale není viditelný
            NavigationLink(
                destination: HalfTimeView()
                    .environmentObject(timerManager),
                isActive: $showHalfTimeView,
                label: { EmptyView() }
            ).hidden()
        }
        .onAppear {
            timerManager.startTimer()
            // Přidáno pro zavření HalfTimeView
            NotificationCenter.default.addObserver(forName: .closeHalfTimeView, object: nil, queue: .main) { _ in
                showHalfTimeView = false
            }
        }
        .onDisappear {
            // Uklidíme observer
            NotificationCenter.default.removeObserver(self, name: .closeHalfTimeView, object: nil)
        }
        .onReceive(timerManager.$elapsedTime) { time in
            // Pro testování: 10 a 20 sekund místo 2700 (45 minut)
            if (time == 10 || time == 20) && !showOvertimeTimer {
                withAnimation {
                    showOvertimeTimer = true
                    timerManager.stopTimer()
                }
            } else if (time > 10 && time < 20) || time > 20 && showOvertimeTimer {
                // Skryjeme časovač nastavení mezi 10. a 20. sekundou a po 20. sekundě
                withAnimation {
                    showOvertimeTimer = false
                }
            }
        }
        .onReceive(overtimeTimer) { _ in
            if showOvertimeTimer {
                overtimeElapsed += 1
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct MatchTimer_Previews: PreviewProvider {
    static var previews: some View {
        MatchTimer(matchId: 1)
    }
} 