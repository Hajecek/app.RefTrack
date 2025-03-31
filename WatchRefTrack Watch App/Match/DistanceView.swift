import SwiftUI

struct DistanceView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Uběhnutá vzdálenost")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                Text("0 km")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
} 