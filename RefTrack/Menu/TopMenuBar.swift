//
//  TopMenuBar.swift
//  RefTrack
//

import SwiftUI

struct TopMenuBar: View {
    var onAddTap: () -> Void
    var onProfileTap: () -> Void
    var isLoggedIn: Bool = false
    var profileImage: String? = nil
    
    var body: some View {
        HStack(alignment: .center) {
            Text("Nadcházející")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: onAddTap) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            .padding(.trailing, 2)
            
            Button(action: onProfileTap) {
                if isLoggedIn && profileImage != nil {
                    // Zobrazení profilového obrázku
                    AsyncImage(url: URL(string: "http://10.0.0.15/reftrack/auth/images/\(profileImage!)")) { phase in
                        switch phase {
                        case .empty:
                            // Zobrazíme placeholder během načítání
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        case .success(let image):
                            // Úspěšně načtený obrázek
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                        case .failure:
                            // Pokud se obrázek nepodaří načíst
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        @unknown default:
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                    }
                } else {
                    // Klasická ikona pro nepřihlášeného uživatele
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .frame(height: 60)
    }
}

#Preview {
    ZStack {
        Color.black
        TopMenuBar(
            onAddTap: {},
            onProfileTap: {}
        )
    }
} 
