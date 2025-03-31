import SwiftUI

struct MatchScreenView: View {
    let matchId: Int
    let homeTeam: String
    let awayTeam: String
    @StateObject private var timerManager = MatchTimerManager()
    
    var body: some View {
        TabView {
            ZStack {
                Color.blue.edgesIgnoringSafeArea(.all)
                MatchTimer(matchId: matchId)
                    .environmentObject(timerManager)
            }
            
            DistanceView()
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct MatchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MatchScreenView(
            matchId: 1,
            homeTeam: "FC Sparta Praha",
            awayTeam: "SK Slavia Praha"
        )
    }
}
