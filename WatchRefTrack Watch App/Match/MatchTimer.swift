import SwiftUI
import AVFoundation

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
    @State private var showContinueSecondHalfScreen = false
    @State private var audioEngine = AVAudioEngine()
    @State private var audioSession = AVAudioSession.sharedInstance()
    @State private var showFinalScreen = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showFinalScreen {
                    // Závěrečná obrazovka
                    Color.black.edgesIgnoringSafeArea(.all)
                    ScrollView {
                        VStack(spacing: 8) {
                            // Základní informace
                            InfoBox {
                                VStack(spacing: 4) {
                                    Text("ZÁPAS")
                                        .font(.system(size: 14, weight: .bold))
                                    
                                    HStack(alignment: .center, spacing: 4) {
                                        Text(homeTeam.prefix(10))
                                            .font(.system(size: 14, weight: .semibold))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                        
                                        Text("vs")
                                            .font(.system(size: 12))
                                        
                                        Text(awayTeam.prefix(10))
                                            .font(.system(size: 14, weight: .semibold))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }
                                }
                            }
                            
                            // Časy
                            InfoBox {
                                HStack(spacing: 12) {
                                    VStack(spacing: 2) {
                                        Text("1. POLOČAS")
                                            .font(.system(size: 10))
                                        Text(timeString(from: firstHalfDuration))
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    
                                    VStack(spacing: 2) {
                                        Text("2. POLOČAS")
                                            .font(.system(size: 10))
                                        Text(timeString(from: secondHalfDuration))
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                }
                            }
                            
                            // Vzdálenost
                            InfoBox {
                                VStack(spacing: 2) {
                                    Text("UBĚHNUTO")
                                        .font(.system(size: 10))
                                    Text("\(String(format: "%.1f", sharedData.distance / 1000)) km")
                                        .font(.system(size: 14, weight: .medium))
                                }
                            }
                            
                            // Skóre
                            InfoBox {
                                HStack(spacing: 12) {
                                    VStack(spacing: 2) {
                                        Text(homeTeam.prefix(6))
                                            .font(.system(size: 10))
                                        Text("\(sharedData.homeGoals)")
                                            .font(.system(size: 18, weight: .bold))
                                    }
                                    
                                    Text(":")
                                        .font(.system(size: 18, weight: .bold))
                                    
                                    VStack(spacing: 2) {
                                        Text(awayTeam.prefix(6))
                                            .font(.system(size: 10))
                                        Text("\(sharedData.awayGoals)")
                                            .font(.system(size: 18, weight: .bold))
                                    }
                                }
                            }
                            
                            // Karty
                            InfoBox {
                                HStack(spacing: 12) {
                                    VStack(spacing: 2) {
                                        Text("🟡")
                                            .font(.system(size: 16))
                                        Text("\(sharedData.homeYellowCards)-\(sharedData.awayYellowCards)")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    
                                    VStack(spacing: 2) {
                                        Text("🔴")
                                            .font(.system(size: 16))
                                        Text("\(sharedData.homeRedCards)-\(sharedData.awayRedCards)")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                }
                            }

                            // Tlačítko pro odeslání
                            Button(action: {
                                print("Domácí skóre: \(sharedData.homeGoals)")
                                print("Hosté skóre: \(sharedData.awayGoals)")
                                print("Žluté karty domácí: \(sharedData.homeYellowCards)")
                                print("Žluté karty hosté: \(sharedData.awayYellowCards)")
                                print("Červené karty domácí: \(sharedData.homeRedCards)")
                                print("Červené karty hosté: \(sharedData.awayRedCards)")
                                print("Vzdálenost: \(String(format: "%.1f", sharedData.distance / 1000)) km")
                                print("Čas prvního poločasu: \(timeString(from: firstHalfDuration))")
                                print("Čas druhého poločasu: \(timeString(from: secondHalfDuration))")
                            }) {
                                Text("ODESLAT DATA")
                                    .font(.system(size: 14, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue)
                                    )
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 20)
                    }
                } else if isHalfTimePauseActive {
                    if showContinueSecondHalfScreen {
                        // Červená obrazovka pro pokračování
                        Color.red
                            .edgesIgnoringSafeArea(.all)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                endHalfTimePause()
                            }
                        VStack {
                            Text("POKRAČOVAT 2. POLOČAS")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Text("Stačí písknout pro spuštění časovače")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.bottom, 20)
                        }
                        .onAppear {
                            setupAudioDetection()
                        }
                        .onDisappear {
                            stopAudioDetection()
                        }
                    } else {
                        // Žlutá obrazovka pauzy
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
                if !isHalfTimePauseActive && !showFinalScreen {
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
                    showContinueSecondHalfScreen = true
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
            showFinalScreen = true
            // Zastavíme dialogové okno pro ukončení zápasu
            showEndHalfAlert = false
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
                // Zobrazíme červenou obrazovku místo přímého pokračování
                showContinueSecondHalfScreen = true
            }
        }
    }
    
    private func endHalfTimePause() {
        // Zastavíme audio detekci
        stopAudioDetection()
        
        // Skryjeme červenou obrazovku
        showContinueSecondHalfScreen = false
        
        // Ukončíme pauzu
        isHalfTimePauseActive = false
        
        // Nastavíme druhý poločas
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
    
    private func setupAudioDetection() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, time in
                let samples = buffer.floatChannelData![0]
                let frameCount = UInt(buffer.frameLength)
                
                var maxAmplitude: Float = 0.0
                for i in 0..<frameCount {
                    let amplitude = abs(samples[Int(i)])
                    if amplitude > maxAmplitude {
                        maxAmplitude = amplitude
                    }
                }
                
                let whistleThreshold: Float = 0.7
                if maxAmplitude > whistleThreshold {
                    DispatchQueue.main.async {
                        if self.showContinueSecondHalfScreen {
                            self.endHalfTimePause()
                        }
                    }
                }
            }
            
            try audioEngine.start()
            print("Audio detekce spuštěna")
            
        } catch {
            print("Chyba při nastavení audio detekce: \(error.localizedDescription)")
        }
    }
    
    private func stopAudioDetection() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        print("Audio detekce zastavena")
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