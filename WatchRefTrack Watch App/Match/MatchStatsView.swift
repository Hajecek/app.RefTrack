import SwiftUI

struct MatchStatsView: View {
    let matchId: Int
    let homeTeam: String
    let awayTeam: String
    @StateObject private var stats = MatchStats()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Skóre s pozadím
                GeometryReader { geometry in
                    ZStack {
                        // Pozadí přes celou šířku
                        HStack(spacing: 0) {
                            Color.blue.opacity(0.05)
                                .frame(width: geometry.size.width / 2)
                            
                            Color.red.opacity(0.05)
                                .frame(width: geometry.size.width / 2)
                        }
                        
                        // Skóre
                        HStack(spacing: 8) {
                            TeamScoreView(teamName: homeTeam, 
                                        value: $stats.homeGoals,
                                        color: .blue)
                            
                            Text(":")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            TeamScoreView(teamName: awayTeam, 
                                        value: $stats.awayGoals,
                                        color: .red)
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .frame(height: 100) // Optimální výška pro watchOS
                
                // Karty
                VStack(spacing: 12) {
                    TeamCardsView(teamName: homeTeam,
                                yellowCards: $stats.homeYellowCards,
                                redCards: $stats.homeRedCards)
                    
                    TeamCardsView(teamName: awayTeam,
                                yellowCards: $stats.awayYellowCards,
                                redCards: $stats.awayRedCards)
                }
                .padding(8)
            }
        }
    }
}

struct TeamScoreView: View {
    let teamName: String
    @Binding var value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(teamName)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundColor(.primary)
            
            Text("\(value)")
                .font(.system(size: 28, weight: .bold))
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .cornerRadius(10)
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
            
            HStack(spacing: 12) {
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
                .font(.system(size: 20))
            
            Text("\(value)")
                .font(.system(size: 20, weight: .medium))
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
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