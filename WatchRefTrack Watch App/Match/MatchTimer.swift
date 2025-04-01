import SwiftUI

struct MatchTimer: View {
    let matchId: Int
    let homeTeam: String
    let awayTeam: String
    
    @EnvironmentObject private var sharedData: SharedData
    @EnvironmentObject private var timerManager: MatchTimerManager
    @State private var firstHalfDuration: TimeInterval = 0
    @State private var secondHalfDuration: TimeInterval = 0
    
    public init(matchId: Int, homeTeam: String, awayTeam: String) {
        self.matchId = matchId
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
    }
    
    @State private var showOvertimeTimer = false
    @State private var overtimeElapsed: TimeInterval = 0
    @State private var overtimeTimer: Timer? = nil
    @State private var showEndHalfAlert = false
    @State private var isFirstHalf = true
    @State private var showHalfTimeView = false
    @State private var showMatchResult = false
    
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
                            .fill(timerManager.isOvertimeRunning ? Color.green.opacity(0.2) : Color.white.opacity(0.1))
                            .animation(.easeInOut(duration: 0.5), value: timerManager.isOvertimeRunning)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                // Dodatečný časovač nastavení
                if timerManager.isOvertimeRunning {
                    Text("+ \(timerManager.overtimeTimeString())")
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
            .alert(isFirstHalf ? "Ukončit 1. poločas?" : "Ukončit zápas?", isPresented: $showEndHalfAlert) {
                Button("OK", role: .destructive) {
                    let totalTime = round(timerManager.elapsedTime + timerManager.overtimeElapsed)
                    
                    if isFirstHalf {
                        firstHalfDuration = totalTime
                        print("Zápas ID: \(matchId), 1. poločas: \(totalTime) sekund")
                        showHalfTimeView = true
                    } else {
                        secondHalfDuration = totalTime
                        print("Zápas ID: \(matchId), 2. poločas: \(totalTime) sekund")
                        showMatchResult = true
                    }
                    
                    // Zastavíme časovač nastavení
                    timerManager.stopOvertimeTimer()
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
            
            NavigationLink(
                destination: MatchResultView(
                    matchId: matchId,
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                    firstHalfTime: firstHalfDuration,
                    secondHalfTime: secondHalfDuration,
                    distance: sharedData.distance
                ),
                isActive: $showMatchResult,
                label: { EmptyView() }
            ).hidden()
        }
        .onAppear {
            if !timerManager.isMainTimerStopped && !timerManager.isOvertimeRunning {
                timerManager.startTimer()
            }
            
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
            if (time == 10 || time == 20) && !timerManager.isOvertimeRunning {
                withAnimation {
                    timerManager.startOvertimeTimer()
                }
            } else if (time > 10 && time < 20) || time > 20 && timerManager.isOvertimeRunning {
                // Skryjeme časovač nastavení mezi 10. a 20. sekundou a po 20. sekundě
                withAnimation {
                    timerManager.stopOvertimeTimer()
                    // Pokud jsme mezi 10. a 20. sekundou, pokračujeme s hlavním časovačem
                    if time > 10 && time < 20 {
                        timerManager.startTimer()
                        timerManager.isMainTimerStopped = false
                    }
                }
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
        MatchTimer(
            matchId: 1,
            homeTeam: "FC Sparta Praha",
            awayTeam: "SK Slavia Praha"
        )
    }
} 