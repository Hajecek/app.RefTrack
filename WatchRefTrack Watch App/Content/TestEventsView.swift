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

struct TestEventsView: View {
    @State private var matches: [Match] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !isLoggedIn {
                Text("Pro zobrazení zápasů se prosím přihlaste")
                    .foregroundColor(.white)
            } else {
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text("Chyba: \(error)")
                        .foregroundColor(.red)
                } else if matches.isEmpty {
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
                    ForEach(matches) { match in
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
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .onAppear {
            fetchMatches()
        }
    }
    
    private func fetchMatches() {
        isLoading = true
        errorMessage = nil
        
        // Kontrola přihlášení
        guard isLoggedIn else {
            errorMessage = "Uživatel není přihlášen"
            isLoading = false
            return
        }
        
        // Získání user_id z UserDefaults
        guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
            // Debug výpis pro kontrolu všech uložených hodnot
            print("Všechny uložené hodnoty v UserDefaults:")
            UserDefaults.standard.dictionaryRepresentation().forEach { print("\($0.key): \($0.value)") }
            
            errorMessage = "Nepodařilo se získat ID uživatele"
            isLoading = false
            return
        }
        
        print("Načteno user_id: \(userId)")  // Debug výpis
        
        guard let url = URL(string: "http://10.0.0.15/reftrack/admin/api/users_matches-api.php?user_id=\(userId)") else {
            errorMessage = "Neplatná URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Chyba sítě: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Neplatná odpověď serveru"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Žádná data nebyla přijata"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(APIResponse.self, from: data)
                    print("Full API Response: \(apiResponse)")  // Debug výpis
                    self.matches = apiResponse.matches
                    self.errorMessage = nil
                    
                } catch {
                    self.errorMessage = "Chyba při zpracování dat"
                }
            }
        }
        task.resume()
    }
    
    private func abbreviateTeamName(_ teamName: String) -> String {
        let words = teamName.components(separatedBy: " ")
        guard !words.isEmpty else { return teamName }
        
        // Pokud je název jednoslovný, vrátíme první 3 písmena
        if words.count == 1 {
            return String(teamName.prefix(3)).uppercased()
        }
        
        // Pro víceslovné názvy vrátíme iniciály
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
} 
