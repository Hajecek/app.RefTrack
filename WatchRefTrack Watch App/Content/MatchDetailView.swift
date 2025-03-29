import SwiftUI

struct MatchDetailView: View {
    let matchId: Int
    let homeTeam: String
    let awayTeam: String
    let role: String
    let matchDate: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                Text(formatDate(matchDate))
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
                
                HStack(alignment: .center, spacing: 6) {
                    Text(homeTeam)
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text("vs")
                        .font(.caption)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 2)
                    
                    Text(awayTeam)
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 4)
                
                Text("Role: \(role)")
                    .font(.caption)
                    .foregroundColor(.yellow)
                
                Button(action: {
                    // Akce pro zahájení zápasu
                    print("Zahájení zápasu s ID: \(matchId)")
                }) {
                    NavigationLink(destination: StartingScreenView(
                        matchId: matchId, 
                        homeTeam: homeTeam, 
                        awayTeam: awayTeam
                    )) {
                        Text("Přejít k zápasu")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 10)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Detail")
        .navigationBarBackButtonHidden(false)
    }
    
    private func formatDate(_ dateString: String) -> String {
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
            matchDate: "2023-12-15T18:00:00"
        )
    }
} 
