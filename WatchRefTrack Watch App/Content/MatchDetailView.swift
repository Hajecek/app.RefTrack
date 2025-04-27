import SwiftUI

struct MatchDetailView: View {
    let matchId: Int
    let homeTeam: String?
    let awayTeam: String?
    let role: String?
    let matchDate: String?
    let location: String?
    let competition: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Text(formatDate(matchDate))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    .padding(.vertical, 8)
                
                VStack(alignment: .center, spacing: 8) {
                    Text(homeTeam ?? "Neznámý tým")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Text("vs")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.yellow)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Text(awayTeam ?? "Neznámý tým")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .background(Color.black.opacity(0.2))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Role: \(role ?? "Neznámá role")")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    Text("Místo: \(location ?? "Neznámé místo")")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    Text("Soutěž: \(competition ?? "Neznámá soutěž")")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.1))
                .cornerRadius(8)
                
                Button(action: {
                    // Akce pro zahájení zápasu
                    print("Zahájení zápasu s ID: \(matchId)")
                }) {
                    NavigationLink(destination: StartingScreenView(
                        matchId: matchId, 
                        homeTeam: homeTeam ?? "", 
                        awayTeam: awayTeam ?? ""
                    )) {
                        Text("Přejít k zápasu")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 16)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Detail zápasu")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "Neznámé datum" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
}

struct MatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MatchDetailView(
            matchId: 1, 
            homeTeam: "FC Sparta Praha", 
            awayTeam: "SK Slavia Praha",
            role: "Rozhodčí",
            matchDate: "2023-12-15T18:00:00",
            location: "Stadion Letná",
            competition: "Fortuna liga"
        )
    }
} 
