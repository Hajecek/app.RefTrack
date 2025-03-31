import SwiftUI

struct MatchScreenView: View {
    let matchId: Int
    let homeTeam: String
    let awayTeam: String
    @StateObject private var timerManager = MatchTimerManager()
    @State private var showHalfTimeView = false
    
    var body: some View {
        TabView {
            ZStack {
                Color.blue.edgesIgnoringSafeArea(.all)
                MatchTimer(matchId: matchId)
                    .environmentObject(timerManager)
            }
            
            DistanceView()
            
            NavigationLink(
                destination: HalfTimeView()
                    .environmentObject(timerManager),
                isActive: $showHalfTimeView,
                label: { EmptyView() }
            ).hidden()
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
