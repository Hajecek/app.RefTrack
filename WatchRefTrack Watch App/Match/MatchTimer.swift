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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
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
                
                // Neviditelný obdélník pro zachycení gesta kliknutí
                Color.clear
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showEndHalfAlert = true
                    }
            }
            .alert(isFirstHalf ? "Ukončit 1. poločas?" : "Ukončit zápas?", isPresented: $showEndHalfAlert) {
                Button("OK", role: .destructive) {
                    let totalTime = round(timerManager.elapsedTime + timerManager.overtimeElapsed)
                    
                    if isFirstHalf {
                        print("Ukončuji 1. poločas a otevírám HalfTimeView")
                        firstHalfDuration = totalTime
                        print("Zápas ID: \(matchId), 1. poločas: \(totalTime) sekund")
                        
                        // Zastavíme všechny časovače
                        timerManager.stopTimer()
                        timerManager.stopOvertimeTimer()
                        
                        // Explicitně nastavíme showHalfTimeView na true
                        showHalfTimeView = true
                    } else {
                        secondHalfDuration = totalTime
                        print("Zápas ID: \(matchId), 2. poločas: \(totalTime) sekund")
                        showMatchResult = true
                        
                        // Zastavíme časovač nastavení
                        timerManager.stopOvertimeTimer()
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
            print("MatchTimer se zobrazuje, showHalfTimeView: \(showHalfTimeView)")
            // Spustíme časovač pouze pokud není zobrazen HalfTimeView
            if !timerManager.isMainTimerStopped && !timerManager.isOvertimeRunning && !showHalfTimeView {
                timerManager.startTimer()
            }
            
            // Přidáno pro zavření HalfTimeView
            NotificationCenter.default.addObserver(forName: .closeHalfTimeView, object: nil, queue: .main) { _ in
                showHalfTimeView = false
                
                // Pokud se vracíme z přestávky, znovu spustíme časovač pro druhý poločas
                if !isFirstHalf {
                    // Začneme druhý poločas
                    timerManager.startTimer()
                }
            }
        }
        .onDisappear {
            // Uklidíme observer
            NotificationCenter.default.removeObserver(self, name: .closeHalfTimeView, object: nil)
        }
        .onReceive(timerManager.$elapsedTime) { time in
            if isFirstHalf {
                // První poločas
                if time >= 10 && !timerManager.isOvertimeRunning {
                    withAnimation {
                        timerManager.startOvertimeTimer()
                    }
                }
            } else {
                // Druhý poločas
                if time >= 20 && !timerManager.isOvertimeRunning {
                    withAnimation {
                        timerManager.startOvertimeTimer()
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