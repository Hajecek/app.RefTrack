//
//  TopMenuBar.swift
//  RefTrack
//

import SwiftUI

struct TopMenuBar: View {
    var onAddTap: () -> Void
    var onProfileTap: () -> Void
    var isLoggedIn: Bool
    var profileImage: String?
    var onLoginStatusChanged: (() -> Void)?
    @State private var selectedFilter = "Nadcházející"
    @State private var showFilterMenu = false
    @Binding var currentFilter: String
    @State private var showProfileView = false
    
    var body: some View {
        HStack(alignment: .center) {
            Menu {
                Button(action: {
                    selectedFilter = "Nadcházející"
                    currentFilter = "Nadcházející"
                }) {
                    Label("Nadcházející (2)", systemImage: "calendar")
                }
                
                Button(action: {
                    selectedFilter = "Předchozí"
                    currentFilter = "Předchozí"
                }) {
                    Label("Předchozí", systemImage: "arrow.clockwise")
                }
                
                Button(action: {
                    selectedFilter = "Probíhá"
                    currentFilter = "Probíhá"
                }) {
                    Label("Probíhá", systemImage: "pencil")
                }
                
                Button(action: {
                    selectedFilter = "Pořádám"
                    currentFilter = "Pořádám"
                }) {
                    Label("Pořádám (2)", systemImage: "crown")
                }
                
                Button(action: {
                    selectedFilter = "Zúčastním se"
                    currentFilter = "Zúčastním se"
                }) {
                    Label("Zúčastním se", systemImage: "checkmark.circle")
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedFilter)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white)
                        .font(.title3)
                        .padding(.top, 4)
                }
            }
            .menuStyle(DefaultMenuStyle())
            .foregroundColor(.white)
            
            Spacer()
            
            Button(action: onAddTap) {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            .padding(.trailing, 8)
            
            Button(action: {
                showProfileView = true
                onProfileTap()
            }) {
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
                                .frame(width: 40, height: 40)
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
            .sheet(isPresented: $showProfileView) {
                ProfileView(initialIsLoggedIn: isLoggedIn)
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
            onProfileTap: {},
            isLoggedIn: false,
            profileImage: nil,
            currentFilter: .constant("Nadcházející")
        )
    }
} 
