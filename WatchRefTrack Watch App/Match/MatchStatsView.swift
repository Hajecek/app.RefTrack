import SwiftUI

struct MatchStatsView: View {
    let matchId: Int
    let homeTeam: String
    let awayTeam: String
    @StateObject private var stats = MatchStats()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Skóre jako dominanta
                GeometryReader { geometry in
                    ZStack {
                        // Pozadí přes celou šířku
                        HStack(spacing: 0) {
                            Color.blue.opacity(0.05)
                                .frame(width: geometry.size.width / 2)
                            
                            Color.red.opacity(0.05)
                                .frame(width: geometry.size.width / 2)
                        }
                        
                        // Skóre uprostřed
                        VStack(spacing: 4) {
                            // Názvy týmů nad skóre
                            HStack(spacing: 12) {
                                Text(homeTeam)
                                    .font(.system(size: 14, weight: .medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(awayTeam)
                                    .font(.system(size: 14, weight: .medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .foregroundColor(.primary)
                            }
                            .frame(width: geometry.size.width * 0.8)
                            .padding(.horizontal, 16)
                            
                            // Skóre
                            HStack(spacing: 12) {
                                TeamScoreView(value: $stats.homeGoals,
                                            color: .blue)
                                
                                Text(":")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                TeamScoreView(value: $stats.awayGoals,
                                            color: .red)
                            }
                        }
                        .frame(width: geometry.size.width)
                    }
                }
                .frame(height: 160) // Dominantní výška pro skóre
                
                // Zbytek obsahu (karty)
                VStack(spacing: 16) {
                    TeamCardsView(teamName: homeTeam,
                                yellowCards: $stats.homeYellowCards,
                                redCards: $stats.homeRedCards)
                    
                    TeamCardsView(teamName: awayTeam,
                                yellowCards: $stats.awayYellowCards,
                                redCards: $stats.awayRedCards)
                }
                .padding(16)
            }
        }
    }
}

struct TeamScoreView: View {
    @Binding var value: Int
    let color: Color
    
    var body: some View {
        Text("\(value)")
            .font(.system(size: 56, weight: .bold))
            .frame(width: 80, height: 80)
            .background(color.opacity(0.1))
            .cornerRadius(16)
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                if value > 0 { value -= 1 }
            }
            .onTapGesture(count: 1) {
                value += 1
            }
    }
}

struct TeamCardsView: View {
    let teamName: String
    @Binding var yellowCards: Int
    @Binding var redCards: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(teamName)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                CardControl(type: "🟡", value: $yellowCards)
                CardControl(type: "🔴", value: $redCards)
            }
        }
    }
}

struct CardControl: View {
    let type: String
    @Binding var value: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(type)
                .font(.system(size: 24))
            
            Text("\(value)")
                .font(.system(size: 24, weight: .medium))
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .contentShape(Rectangle())
                .onTapGesture(count: 2) {
                    if value > 0 { value -= 1 }
                }
                .onTapGesture(count: 1) {
                    value += 1
                }
        }
    }
}

class MatchStats: ObservableObject {
    @Published var homeGoals = 0
    @Published var awayGoals = 0
    @Published var homeYellowCards = 0
    @Published var awayYellowCards = 0
    @Published var homeRedCards = 0
    @Published var awayRedCards = 0
}

struct MatchStatsView_Previews: PreviewProvider {
    static var previews: some View {
        MatchStatsView(
            matchId: 1,
            homeTeam: "Sparta",
            awayTeam: "Slavia"
        )
    }
} 