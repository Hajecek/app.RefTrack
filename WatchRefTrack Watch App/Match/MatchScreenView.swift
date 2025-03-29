import SwiftUI

struct MatchScreenView: View {
    let matchId: Int
    let homeTeam: String
    let awayTeam: String
    
    var body: some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(.all)
            
            Text("Ahoj")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
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
