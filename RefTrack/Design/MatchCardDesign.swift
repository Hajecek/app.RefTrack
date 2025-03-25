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
                            Color(red: 0.0, green: 0.44, blue: 0.8),  // Světlejší modrá podobná screenshotu
                            Color(red: 0.0, green: 0.22, blue: 0.55)   // Tmavší modrá
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: UIScreen.main.bounds.width - 40, height: 600)
                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
            
            // Obsah karty
            VStack(alignment: .leading, spacing: 0) {
                // Horní část s bannerem - skleněný efekt
                HStack {
                    // Vlastní tvar se skleněným efektem pro banner
                    Group {
                        HStack(spacing: 6) {
                            Image(systemName: "sharedwithyou") // Alternativní ikona místo nedostupné whistle.fill
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .shadow(color: .white.opacity(0.3), radius: 1)
                            Text(match.role ?? "")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.6),
                                                    Color.white.opacity(0.1)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        )
                    }
                    .padding(.leading, -5)
                    
                    Spacer()
                }
                .padding(.top, 30)
                
                // Hlavní obsah
                VStack(spacing: 25) {
                    Spacer()
                    
                    Text(match.competition)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 20) {
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
                    .padding(.vertical, 15)
                    
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Text(formatDate(match.matchDate))
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Název role ve velkém fontu dole - zarovnání doleva (místo location)
                    HStack {
                        Text(match.location)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.bottom, 40)
                        
                        Spacer() // Přidá prostor napravo, což posune text doleva
                    }
                }
                .padding(.top, 10)
            }
            .padding(30)
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        // Zde přidejte formátování data
        return dateString
    }
} 
