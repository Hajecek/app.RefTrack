import SwiftUI
import AVFoundation

struct HalfTimeView: View {
    @EnvironmentObject private var timerManager: MatchTimerManager
    @State private var timeRemaining: TimeInterval = 0 // Inicializováno na 0, bude nastaveno v onAppear
    @State private var showEndScreen = false // Nový stav pro zobrazení koncového screenu
    @State private var audioEngine = AVAudioEngine()
    @State private var audioSession = AVAudioSession.sharedInstance()
    @State private var showSkipDialog = false // Nový stav pro dialogové okno
    
    var body: some View {
        ZStack {
            if showEndScreen {
                // Červená obrazovka po vypršení času
                Color.red.edgesIgnoringSafeArea(.all)
                VStack {
                    Text("POKRAČOVAT 2. POLOČAS")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .minimumScaleFactor(0.8)
                        .lineLimit(2)
                }
                .onAppear {
                    setupAudioDetection()
                }
                .onDisappear {
                    stopAudioDetection()
                }
            } else {
                // Základní obrazovka s žlutým pozadím a časovačem
                Color.yellow.edgesIgnoringSafeArea(.all)
                
                // Hlavní obsah - posun časovače dolů
                VStack {
                    // Titulek "Pauza" zůstává nahoře
                    Text("Pauza")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.top, 20)
                    
                    // Spacer tlačí časovač dolů
                    Spacer()
                    
                    // Časovač umístěný dole
                    Text(timeString(from: timeRemaining))
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10) // Malý padding od spodního okraje
                }
                .edgesIgnoringSafeArea(.bottom)
                .contentShape(Rectangle()) // Pro kliknutí na celou plochu
                .alert("Přeskočit pauzu?", isPresented: $showSkipDialog) {
                    Button("Ano", role: .destructive) { // Role destructive dává tlačítku červenou barvu
                        showEndScreen = true
                    }
                    Button("Ne", role: .cancel) {}
                }
            }
        }
        .onAppear {
            // Nastavení času pauzy z MatchTimerSettings
            timeRemaining = MatchTimerSettings.shared.halfTimePauseInSeconds
            startTimer()
        }
        .onTapGesture {
            if showEndScreen {
                // Spustíme druhý poločas od 10. sekundy
                timerManager.setElapsedTime(10)
                timerManager.startTimer()
                
                // Explicitně zavřeme HalfTimeView
                NotificationCenter.default.post(
                    name: .closeHalfTimeView, 
                    object: nil
                )
            } else {
                showSkipDialog = true
            }
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                showEndScreen = true // Zobrazí červenou obrazovku po vypršení času
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
                        print("Detekováno písknutí!")
                        print("Čas detekce: \(Date())")
                        print("Amplituda zvuku: \(maxAmplitude)")
                        
                        if maxAmplitude >= 1.0 {
                            timerManager.startTimer()
                            NotificationCenter.default.post(
                                name: .closeHalfTimeView, 
                                object: nil
                            )
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

struct HalfTimeView_Previews: PreviewProvider {
    static var previews: some View {
        HalfTimeView()
    }
} 