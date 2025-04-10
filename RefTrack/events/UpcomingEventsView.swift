import SwiftUI

struct UpcomingEventsView: View {
    @State private var matches: [Match] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var timer: Timer?
    @Binding var hasMatches: Bool
    @Binding var upcomingMatchesCount: Int
    
    init(hasMatches: Binding<Bool> = .constant(false), 
         upcomingMatchesCount: Binding<Int> = .constant(0)) {
        self._hasMatches = hasMatches
        self._upcomingMatchesCount = upcomingMatchesCount
    }
    
    var body: some View {
        Group {
            if !isLoggedIn {
                EventView(
                    iconName: "calendar",
                    iconColor: .blue,
                    title: "Nepřihlášen",
                    description: "Pro zobrazení zápasů se prosím přihlaste."
                )
            } else if matches.isEmpty {
                EventView(
                    iconName: "calendar",
                    iconColor: .blue,
                    title: "Žádné nadcházející zápasy",
                    description: "Momentálně nemáte žádné plánované zápasy."
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
            fetchMatches()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
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
    
    private func fetchMatches() {
        isLoading = true
        errorMessage = nil
        
        guard isLoggedIn else {
            errorMessage = "Uživatel není přihlášen"
            isLoading = false
            return
        }
        
        guard let userId = UserDefaults.standard.string(forKey: "user_id") else {
            errorMessage = "Nepodařilo se načíst ID uživatele"
            isLoading = false
            return
        }
        
        print("Fetching matches for user ID: \(userId)")
        print("Current user ID in UserDefaults: \(UserDefaults.standard.string(forKey: "user_id") ?? "N/A")")
        
        guard let url = URL(string: "https://reftrack.cz/admin/api/events/upcoming_events-api.php?user_id=\(userId)") else {
            errorMessage = "Neplatná URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Chyba sítě: \(error.localizedDescription)"
                    return
                }
                
                // Logování odpovědi
                if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                    
                    do {
                        let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                    } catch {
                        print("Error decoding response: \(error)")
                    }
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
                    let apiResponse = try decoder.decode(ApiResponse.self, from: data)
                    
                    if apiResponse.status == "error" {
                        self.errorMessage = apiResponse.message
                        self.hasMatches = false
                        self.upcomingMatchesCount = 0
                    } else {
                        withAnimation {
                            self.matches = apiResponse.matches
                            self.hasMatches = !apiResponse.matches.isEmpty
                            self.upcomingMatchesCount = apiResponse.matches.count
                        }
                    }
                } catch {
                    self.errorMessage = "Chyba při dekódování dat: \(error.localizedDescription)"
                    self.hasMatches = false
                }
            }
        }.resume()
    }
}


