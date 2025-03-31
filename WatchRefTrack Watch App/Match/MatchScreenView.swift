import SwiftUI

struct MatchScreenView: View {
    let matchId: Int
    let homeTeam: String
    let awayTeam: String
    @StateObject private var timerManager = MatchTimerManager()
    @StateObject private var sharedData = SharedData()
    @State private var showHalfTimeView = false
    
    var body: some View {
        TabView {
            ZStack {
                Color.blue.edgesIgnoringSafeArea(.all)
                MatchTimer(matchId: matchId, homeTeam: homeTeam, awayTeam: awayTeam)
                    .environmentObject(timerManager)
                    .environmentObject(sharedData)
            }
            
            DistanceView()
                .environmentObject(sharedData)
            
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
