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
            // WatchOS styl pozadí
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
                                Text(timeString(from: firstHalfTime))
                                    .font(.system(size: 14, weight: .medium))
                            }
                            
                            VStack(spacing: 2) {
                                Text("2. POLOČAS")
                                    .font(.system(size: 10))
                                Text(timeString(from: secondHalfTime))
                                    .font(.system(size: 14, weight: .medium))
                            }
                        }
                    }
                    
                    // Vzdálenost
                    InfoBox {
                        VStack(spacing: 2) {
                            Text("UBĚHNUTO")
                                .font(.system(size: 10))
                            Text("\(String(format: "%.1f", distance / 1000)) km")
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
                        print("Žluté karty hosté: 🟡\(sharedData.awayYellowCards)")
                        print("Červené karty domácí: \(sharedData.homeRedCards)")
                        print("Červené karty hosté: \(sharedData.awayRedCards)")
                        print("Vzdálenost: \(String(format: "%.1f", distance / 1000)) km")
                        print("Čas prvního poločasu: \(timeString(from: firstHalfTime))")
                        print("Čas druhého poločasu: \(timeString(from: secondHalfTime))")
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
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// Pomocná view pro boxy
struct InfoBox<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
                .padding(12)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
        )
        .padding(.vertical, 4)
    }
}

// Preview
struct MatchResultView_Previews: PreviewProvider {
    static var previews: some View {
        MatchResultView(
            matchId: 123,
            homeTeam: "AC Sparta Praha",
            awayTeam: "SK Slavia Praha",
            firstHalfTime: 2700,
            secondHalfTime: 2700,
            distance: 8500
        )
        .environmentObject(SharedData())
    }
} 
