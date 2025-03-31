import SwiftUI
import AVFoundation

struct StartingScreenView: View {
    let matchId: Int
    let homeTeam: String
    let awayTeam: String
    
    @State private var audioEngine = AVAudioEngine()
    @State private var audioSession = AVAudioSession.sharedInstance()
    @State private var navigateToMatch = false
    
    var body: some View {
        ZStack {
            Color.green
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 12) {
                Text("START")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(homeTeam) vs \(awayTeam)")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
            }
        }
        .navigationTitle("Zápas")
        .navigationBarBackButtonHidden(false)
        .contentShape(Rectangle())
        .onTapGesture {
            print("Zápas ID: \(matchId)")
            print("Zápas: \(homeTeam) vs \(awayTeam)")
            self.navigateToMatch = true
        }
        .onAppear {
            setupAudioDetection()
        }
        .onDisappear {
            stopAudioDetection()
        }
        .background(
            NavigationLink(
                destination: MatchScreenView(matchId: matchId, homeTeam: homeTeam, awayTeam: awayTeam),
                isActive: $navigateToMatch,
                label: { EmptyView() }
            )
        )
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
                
                let whistleThreshold: Float = 0.5
                if maxAmplitude > whistleThreshold {
                    DispatchQueue.main.async {
                        print("Detekováno písknutí!")
                        print("Čas detekce: \(Date())")
                        print("Amplituda zvuku: \(maxAmplitude)")
                        
                        if maxAmplitude >= 0.8 {
                            self.navigateToMatch = true
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

struct StartingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        StartingScreenView(
            matchId: 1,
            homeTeam: "FC Sparta Praha",
            awayTeam: "SK Slavia Praha"
        )
    }
} 