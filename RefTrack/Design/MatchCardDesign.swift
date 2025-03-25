import SwiftUI

struct MatchCardDesign: View {
    let match: Match
    
    var body: some View {
        ZStack {
            // Pozadí s gradientem
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "0040DD"),  // Velmi tmavá modrá
                            Color(hex: "0A84FF")   // Středně tmavá Apple modrá
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: UIScreen.main.bounds.width - 40, height: 600)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            
            // Obsah
            VStack(spacing: 30) {
                // Hlavní obsah
                VStack(spacing: 25) {
                    Text(match.competition)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 15) {
                        Text(match.homeTeam)
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("vs")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(match.awayTeam)
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 20)
                    
                    VStack(spacing: 8) {
                        Text(formatDate(match.matchDate))
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 30)
                
                Spacer()
            }
            .padding(30)
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        // Zde přidejte formátování data
        return dateString
    }
} 