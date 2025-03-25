import SwiftUI

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
    @State private var matchesArePrivate = false
    
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
                                .frame(width: UIScreen.main.bounds.width - 40)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
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
                        self.matches = response.matches
                        self.hasMatches = !response.matches.isEmpty
                        self.matchesArePrivate = response.status == "private"
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
        MatchCardDesign(match: match, addedBy: "Uživatel")
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
