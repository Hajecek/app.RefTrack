import SwiftUI

struct HalfTimeView: View {
    @EnvironmentObject private var timerManager: MatchTimerManager
    @State private var timeRemaining: TimeInterval = 5 // Změněno z 900 na 5 sekund
    @State private var showEndScreen = false // Nový stav pro zobrazení koncového screenu
    
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
            } else {
                VStack {
                    Spacer()
                    
                    Text("Pauza")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
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
                    
                    Spacer()
                }
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.yellow.edgesIgnoringSafeArea(.all))
            }
        }
        .onAppear {
            startTimer()
        }
        .onTapGesture {
            if showEndScreen {
                // Prostě spustíme hlavní časovač od aktuálního času
                timerManager.startTimer()
                
                // Skryjeme screen pauzy
                showEndScreen = false
                
                // Zavřeme HalfTimeView
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NotificationCenter.default.post(
                        name: .closeHalfTimeView, 
                        object: nil
                    )
                }
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
}

struct HalfTimeView_Previews: PreviewProvider {
    static var previews: some View {
        HalfTimeView()
    }
} 