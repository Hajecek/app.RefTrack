import SwiftUI

struct Match: Codable, Identifiable {
    let id: String
    let competition: String
    let homeTeam: String
    let awayTeam: String
    let matchDate: String
    let location: String
    let homeScore: String
    let awayScore: String
    // ... další potřebná pole
    
    enum CodingKeys: String, CodingKey {
        case id
        case competition
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case matchDate = "match_date"
        case location
        case homeScore = "home_score"
        case awayScore = "away_score"
        // ... mapování dalších polí
    }
}

struct ApiResponse: Codable {
    let status: String
    let message: String
    let matches: [Match]
}

struct PublicEventsView: View {
    @State private var matches: [Match] = []
    @State private var isLoading = false
    @State private var timer: Timer?
    @Binding var hasMatches: Bool
    
    init(hasMatches: Binding<Bool> = .constant(false)) {
        self._hasMatches = hasMatches
    }
    
    var body: some View {
        Group {
            if matches.isEmpty {
                EventView(
                    iconName: "calendar",
                    iconColor: .blue,
                    title: "Žádné veřejné zápasy",
                    description: "Momentálně nejsou k dispozici žádné veřejné zápasy. Zkuste to prosím později."
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(matches) { match in
                            MatchCard(match: match)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
            }
        }
        .onAppear {
            loadMatches()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        // Aktualizace každou sekundu
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            loadMatches()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func loadMatches() {
        isLoading = true
        guard let url = URL(string: "http://10.0.0.15/reftrack/admin/api/events/public_events-api.php") else { return }
        
        // Přidáme cache policy pro vynucení nového načtení dat
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(ApiResponse.self, from: data)
                        // Aktualizujeme matches pouze pokud se data změnila
                        if self.matches != response.matches {
                            self.matches = response.matches
                            self.hasMatches = !response.matches.isEmpty
                        }
                    } catch {
                        print("Chyba dekódování: \(error)")
                        self.hasMatches = false
                    }
                }
            }
        }.resume()
    }
}

struct MatchCard: View {
    let match: Match
    
    var body: some View {
        ZStack {
            // Pozadí s gradientem
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "FF416C"),
                            Color(hex: "FF4B2B")
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

// Helper pro HEX barvy
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Match: Equatable {
    static func == (lhs: Match, rhs: Match) -> Bool {
        return lhs.id == rhs.id &&
               lhs.competition == rhs.competition &&
               lhs.homeTeam == rhs.homeTeam &&
               lhs.awayTeam == rhs.awayTeam &&
               lhs.matchDate == rhs.matchDate &&
               lhs.homeScore == rhs.homeScore &&
               lhs.awayScore == rhs.awayScore
    }
} 