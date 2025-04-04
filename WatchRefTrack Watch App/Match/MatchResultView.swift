import SwiftUI

struct MatchResultView: View {
    let matchId: Int
    let homeTeam: String
    let awayTeam: String
    let firstHalfTime: TimeInterval
    let secondHalfTime: TimeInterval
    let distance: Double
    @EnvironmentObject private var sharedData: SharedData
    
    var body: some View {
        ZStack {
            Color.purple.edgesIgnoringSafeArea(.all)
            
            ScrollView {
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
                    
                    // Skóre
                    HStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text(homeTeam)
                                .font(.system(size: 12))
                            Text("\(sharedData.homeGoals)")
                                .font(.system(size: 20, weight: .bold))
                        }
                        
                        Text(":")
                            .font(.system(size: 20, weight: .bold))
                        
                        VStack(spacing: 2) {
                            Text(awayTeam)
                                .font(.system(size: 12))
                            Text("\(sharedData.awayGoals)")
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                    
                    // Karty
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("🟡")
                                .font(.system(size: 20))
                            Text("\(sharedData.homeYellowCards)-\(sharedData.awayYellowCards)")
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        VStack(spacing: 4) {
                            Text("🔴")
                                .font(.system(size: 20))
                            Text("\(sharedData.homeRedCards)-\(sharedData.awayRedCards)")
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            print("""
            Zobrazení výsledků zápasu:
            ID zápasu: \(matchId)
            Domácí tým: \(homeTeam)
            Hostující tým: \(awayTeam)
            1. poločas: \(timeString(from: firstHalfTime))
            2. poločas: \(timeString(from: secondHalfTime))
            Uběhnutá vzdálenost: \(String(format: "%.2f", distance / 1000)) km
            Skóre: \(sharedData.homeGoals) - \(sharedData.awayGoals)
            Žluté karty: \(sharedData.homeYellowCards) - \(sharedData.awayYellowCards)
            Červené karty: \(sharedData.homeRedCards) - \(sharedData.awayRedCards)
            """)
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 