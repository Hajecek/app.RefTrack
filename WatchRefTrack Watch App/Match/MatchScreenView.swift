import SwiftUI

struct MatchScreenView: View {
    let matchId: Int
    let homeTeam: String
    let awayTeam: String
    @StateObject private var timerManager = MatchTimerManager()
    @StateObject private var sharedData = SharedData()
    @State private var showHalfTimeView = false
    @StateObject private var tracker = DistanceTracker()
    
    var body: some View {
        TabView {
            ZStack {
                Color.blue.edgesIgnoringSafeArea(.all)
                MatchTimer(matchId: matchId, homeTeam: homeTeam, awayTeam: awayTeam)
                    .environmentObject(sharedData)
                    .environmentObject(timerManager)
            }
            
            DistanceView()
                .environmentObject(sharedData)
                .environmentObject(tracker)
            
            NavigationLink(
                destination: HalfTimeView()
                    .environmentObject(timerManager),
                isActive: $showHalfTimeView,
                label: { EmptyView() }
            ).hidden()
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onAppear {
            tracker.startTracking()
            print("MatchScreenView: Sledování vzdálenosti zahájeno")
        }
        .onDisappear {
            tracker.stopTracking()
            print("MatchScreenView: Sledování vzdálenosti ukončeno")
        }
        .onReceive(tracker.$distance) { distance in
            sharedData.distance = distance
            print("Aktuální uběhnutá vzdálenost: \(String(format: "%.2f", distance / 1000)) km (\(String(format: "%.2f", distance)) m)")
        }
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
