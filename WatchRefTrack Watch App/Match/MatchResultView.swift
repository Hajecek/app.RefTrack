import SwiftUI

struct MatchResultView: View {
    let matchId: Int
    let homeTeam: String
    let awayTeam: String
    let firstHalfTime: TimeInterval
    let secondHalfTime: TimeInterval
    let distance: Double
    
    var body: some View {
        ZStack {
            Color.purple.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 12) {
                // Nadpis
                Text("Konečné statistiky")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
                
                // Týmy - kompaktnější zobrazení
                HStack(alignment: .center, spacing: 8) {
                    Text(homeTeam)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text("vs")
                        .font(.system(size: 14))
                    
                    Text(awayTeam)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                
                // Časy poločasů - v řádku
                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Text("1. poločas")
                            .font(.system(size: 12))
                        Text(timeString(from: firstHalfTime))
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    VStack(spacing: 2) {
                        Text("2. poločas")
                            .font(.system(size: 12))
                        Text(timeString(from: secondHalfTime))
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .foregroundColor(.white)
                .padding(.bottom, 8)
                
                // Vzdálenost
                VStack(spacing: 2) {
                    Text("Uběhnuto")
                        .font(.system(size: 12))
                    Text("\(String(format: "%.2f", distance / 1000)) km")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 