import SwiftUI

struct StartingScreenView: View {
    let matchId: Int
    let homeTeam: String
    let awayTeam: String
    
    var body: some View {
        ZStack {
            // Zelené pozadí přes celou obrazovku
            Color.green
                .edgesIgnoringSafeArea(.all)
            
            // Text START a názvy týmů
            VStack(spacing: 12) {
                Text("START")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(homeTeam) vs \(awayTeam)")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
            }
        }
        .navigationTitle("Zápas")
        .navigationBarBackButtonHidden(false)
        .contentShape(Rectangle()) // Zajistí, že celá plocha je klikatelná
        .onTapGesture {
            print("Zápas ID: \(matchId)")
            print("Zápas: \(homeTeam) vs \(awayTeam)")
        }
    }
}

struct StartingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        StartingScreenView(
            matchId: 1,
            homeTeam: "FC Sparta Praha",
            awayTeam: "SK Slavia Praha"
        )
    }
} 