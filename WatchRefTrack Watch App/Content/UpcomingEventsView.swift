import SwiftUI

struct Match: Identifiable, Codable {
    let id: Int
    let userId: Int
    let competition: String
    let homeTeam: String
    let awayTeam: String
    let matchDate: String
    let location: String?
    let firstHalfDuration: String
    let secondHalfDuration: String
    let totalMatchTime: Int
    let homeScore: Int?
    let awayScore: Int?
    let role: String
    let distanceRun: String?
    let payment: String?
    let yellowCards: Int
    let redCards: Int
    let delegateRating: String?
    let matchReview: String?
    let headReferee: String?
    let assistantReferee1: String?
    let assistantReferee2: String?
    let fourthOfficial: String?
    let delegateName: String?
    let visibility: String
    let status: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case competition
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case matchDate = "match_date"
        case location
        case firstHalfDuration = "first_half_duration"
        case secondHalfDuration = "second_half_duration"
        case totalMatchTime = "total_match_time"
        case homeScore = "home_score"
        case awayScore = "away_score"
        case role
        case distanceRun = "distance_run"
        case payment
        case yellowCards = "yellow_cards"
        case redCards = "red_cards"
        case delegateRating = "delegate_rating"
        case matchReview = "match_review"
        case headReferee = "head_referee"
        case assistantReferee1 = "assistant_referee_1"
        case assistantReferee2 = "assistant_referee_2"
        case fourthOfficial = "fourth_official"
        case delegateName = "delegate_name"
        case visibility
        case status
        case createdAt = "created_at"
    }
}

struct APIResponse: Codable {
    let status: String
    let message: String
    let matches: [Match]
}

struct UpcomingEventsView: View {
    @State private var matches: [Match] = []
    @State private var cachedMatches: [Match] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var timer: Timer?
    @State private var isOnline = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !isLoggedIn {
                Text("Pro zobrazení zápasů se prosím přihlaste")
                    .foregroundColor(.white)
            } else {
                if isLoading && isOnline {
                    ProgressView()
                } else if let error = errorMessage, isOnline {
                    Text("Chyba: \(error)")
                        .foregroundColor(.red)
                } else if matches.isEmpty && cachedMatches.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                        
                        Text("Nemáte žádné naplánované zápasy")
                            .font(.system(size: 12))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal, 8)
                } else {
                    ForEach(isOnline ? matches : cachedMatches) { match in
                        let destinationView = MatchDetailView(
                            matchId: match.id,
                            homeTeam: match.homeTeam,
                            awayTeam: match.awayTeam,
                            role: match.role,
                            matchDate: match.matchDate
                        )
                        
                        NavigationLink(destination: destinationView) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("\(abbreviateTeamName(match.homeTeam)) vs \(abbreviateTeamName(match.awayTeam))")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                    Text("(\(match.role))")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                }
                                
                                Text(formatDate(match.matchDate))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(!isOnline ? Color.yellow : Color.clear, lineWidth: 2)
                            )
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .onAppear {
            loadCachedMatches()
            checkConnection()
            fetchMatches()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func loadCachedMatches() {
        if let data = UserDefaults.standard.data(forKey: "cachedMatches") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Match].self, from: data) {
                cachedMatches = decoded
            }
        }
    }
    
    private func saveMatchesToCache() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(matches) {
            UserDefaults.standard.set(encoded, forKey: "cachedMatches")
        }
    }
    
    private func checkConnection() {
        // Jednoduchá kontrola připojení
        if let url = URL(string: "https://reftrack.cz") {
            let task = URLSession.shared.dataTask(with: url) { _, _, error in
                DispatchQueue.main.async {
                    self.isOnline = error == nil
                }
            }
            task.resume()
        }
    }
    
    private func fetchMatches() {
        guard !isLoading else { return }
        
        let shouldShowLoading = matches.isEmpty
        if shouldShowLoading {
            isLoading = true
        }
        
        guard isLoggedIn else {
            errorMessage = "Uživatel není přihlášen"
            isLoading = false
            return
        }
        
        guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
            errorMessage = "Nepodařilo se získat ID uživatele"
            isLoading = false
            return
        }
        
        guard let url = URL(string: "https://reftrack.cz/admin/api/users_matches-api.php?user_id=\(userId)") else {
            errorMessage = "Neplatná URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if shouldShowLoading {
                    self.isLoading = false
                }
                
                if let error = error {
                    self.errorMessage = "Chyba sítě: \(error.localizedDescription)"
                    self.isOnline = false
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Žádná data nebyla přijata"
                    self.isOnline = false
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(APIResponse.self, from: data)
                    
                    if self.matches != apiResponse.matches {
                        self.matches = apiResponse.matches
                        self.saveMatchesToCache()
                    }
                    self.errorMessage = nil
                    self.isOnline = true
                    
                } catch {
                    self.errorMessage = "Chyba při zpracování dat"
                    self.isOnline = false
                }
            }
        }
        task.resume()
    }
    
    private func abbreviateTeamName(_ teamName: String) -> String {
        let words = teamName.components(separatedBy: " ")
        guard !words.isEmpty else { return teamName }
        
        if words.count == 1 {
            return String(teamName.prefix(3)).uppercased()
        }
        
        return words.map { String($0.prefix(1)) }.joined().uppercased()
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "dd.MM. HH:mm"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            fetchMatches()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
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
               lhs.awayScore == rhs.awayScore &&
               lhs.role == rhs.role &&
               lhs.status == rhs.status
    }
} 
