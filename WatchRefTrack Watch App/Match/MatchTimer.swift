import SwiftUI

// hlavni screen kde bezi casovač

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
    @State private var isHalfTimePauseActive = false
    @State private var halfTimePauseRemaining: TimeInterval = MatchTimerSettings.shared.halfTimePauseInSeconds
    @State private var showSkipPauseDialog = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isHalfTimePauseActive {
                    // Polčasová pauza
                    Color.yellow
                        .edgesIgnoringSafeArea(.all)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showSkipPauseDialog = true
                        }
                    
                    VStack {
                        Text("Pauza")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.top, 10)
                        
                        Text(timeString(from: halfTimePauseRemaining))
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(10)
                    }
                } else {
                    // Hlavní VStack přes celou obrazovku
                    VStack(spacing: 0) {
                        // Skóre a karty - minimalistické zobrazení
                        HStack(spacing: 8) {
                            // Skóre
                            HStack(spacing: 4) {
                                Text("\(sharedData.homeGoals)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(":")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("\(sharedData.awayGoals)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            // Oddělovač
                            Rectangle()
                                .frame(width: 1, height: 20)
                                .foregroundColor(.white.opacity(0.2))
                            
                            // Karty - kompaktnější verze
                            HStack(spacing: 6) {
                                HStack(spacing: 2) {
                                    Text("🟡")
                                        .font(.system(size: 12))
                                    Text("\(sharedData.homeYellowCards)-\(sharedData.awayYellowCards)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                
                                HStack(spacing: 2) {
                                    Text("🔴")
                                        .font(.system(size: 12))
                                    Text("\(sharedData.homeRedCards)-\(sharedData.awayRedCards)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.top, 8)
                        
                        // Indikátor poločasu
                        Text(isFirstHalf ? "1. POLOČAS" : "2. POLOČAS")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 8)
                        
                        Spacer()
                        
                        if timerManager.isOvertimeRunning {
                            VStack(spacing: 4) {
                                Text("NASTAVENÍ")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.bottom, 2)
                                
                                Text("+ \(timerManager.overtimeTimeString())")
                                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.green.opacity(0.2))
                            )
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 10)
                            .transition(.opacity.combined(with: .scale))
                        } else {
                            Text(timerManager.timeString())
                                .font(.system(size: 56, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.white.opacity(0.1))
                                )
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 10)
                        }
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
                
                // Neviditelný obdélník pro zachycení gesta kliknutí pouze když není pauza
                if !isHalfTimePauseActive {
                    Color.clear
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showEndHalfAlert = true
                        }
                }
            }
            .alert(isFirstHalf ? "Ukončit 1. poločas?" : "Ukončit zápas?", isPresented: $showEndHalfAlert) {
                Button("OK", role: .destructive) {
                    handleHalfTimeEnd()
                }
                Button("Zrušit", role: .cancel) {}
            }
            .alert("Přeskočit polčasovou pauzu?", isPresented: $showSkipPauseDialog) {
                Button("Ano", role: .destructive) {
                    endHalfTimePause()
                }
                Button("Ne", role: .cancel) {}
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
                )
                .environmentObject(sharedData),
                isActive: $showMatchResult,
                label: { EmptyView() }
            ).hidden()
        }
        .onAppear {
            if !timerManager.isMainTimerStopped && !timerManager.isOvertimeRunning {
                timerManager.startTimer()
            }
        }
        .onReceive(timerManager.$elapsedTime) { time in
            checkForHalfTimeTransition(time: time)
        }
    }
    
    private func handleHalfTimeEnd() {
        timerManager.stopTimer()
        timerManager.stopOvertimeTimer()
        
        if isFirstHalf {
            startHalfTimePause()
        } else {
            showMatchResult = true
        }
    }
    
    private func startHalfTimePause() {
        isHalfTimePauseActive = true
        halfTimePauseRemaining = MatchTimerSettings.shared.halfTimePauseInSeconds
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if halfTimePauseRemaining > 0 {
                halfTimePauseRemaining -= 1
            } else {
                timer.invalidate()
                endHalfTimePause()
            }
        }
    }
    
    private func endHalfTimePause() {
        isHalfTimePauseActive = false
        isFirstHalf = false
        timerManager.setElapsedTime(MatchTimerSettings.shared.firstHalfTimeInSeconds)
        timerManager.startTimer()
    }
    
    private func checkForHalfTimeTransition(time: TimeInterval) {
        if isFirstHalf {
            if time >= MatchTimerSettings.shared.firstHalfTimeInSeconds && !timerManager.isOvertimeRunning {
                timerManager.startOvertimeTimer()
            }
        } else {
            if time >= MatchTimerSettings.shared.firstHalfTimeInSeconds + MatchTimerSettings.shared.secondHalfTimeInSeconds && !timerManager.isOvertimeRunning {
                timerManager.startOvertimeTimer()
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