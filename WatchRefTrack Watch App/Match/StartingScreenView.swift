import SwiftUI

struct StartingScreenView: View {
    let matchId: Int
    
    var body: some View {
        ZStack {
            // Zelené pozadí přes celou obrazovku
            Color.green
                .edgesIgnoringSafeArea(.all)
            
            // Text START uprostřed obrazovky - výrazně větší
            Text("START")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
        }
        .navigationTitle("Zápas")
        .navigationBarBackButtonHidden(false)
    }
}

struct StartingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        StartingScreenView(matchId: 1)
    }
} 