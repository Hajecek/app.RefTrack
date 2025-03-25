//
//  TopMenuBar.swift
//  RefTrack
//

import SwiftUI

struct TopMenuBar: View {
    var onAddTap: () -> Void
    var onProfileTap: () -> Void
    var onStatsTap: () -> Void
    var isLoggedIn: Bool
    var profileImage: String?
    var onLoginStatusChanged: (() -> Void)?
    @State private var selectedFilter: String
    @State private var showFilterMenu = false
    @Binding var currentFilter: String
    @State private var showProfileView = false
    @State private var showStatisticsView = false
    
    init(onAddTap: @escaping () -> Void, 
         onProfileTap: @escaping () -> Void,
         onStatsTap: @escaping () -> Void,
         isLoggedIn: Bool, 
         profileImage: String?, 
         onLoginStatusChanged: (() -> Void)?, 
         currentFilter: Binding<String>) {
        self.onAddTap = onAddTap
        self.onProfileTap = onProfileTap
        self.onStatsTap = onStatsTap
        self.isLoggedIn = isLoggedIn
        self.profileImage = profileImage
        self.onLoginStatusChanged = onLoginStatusChanged
        self._currentFilter = currentFilter
        self._selectedFilter = State(initialValue: currentFilter.wrappedValue)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Menu {
                Button(action: {
                    selectedFilter = "Budoucí"
                    currentFilter = "Budoucí"
                }) {
                    Label("Budoucí (2)", systemImage: "calendar")
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
                    selectedFilter = "Veřejné"
                    currentFilter = "Veřejné"
                }) {
                    Label("Veřejné", systemImage: "checkmark.circle")
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
            .padding(.trailing, 2)
            
            Button(action: {
                showStatisticsView = true
                onStatsTap()
            }) {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            .sheet(isPresented: $showStatisticsView) {
                StatisticsView()
            }
            .padding(.trailing, 2)
            
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
        .onChange(of: currentFilter) { newValue in
            selectedFilter = newValue
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
            onStatsTap: {},
            isLoggedIn: false,
            profileImage: nil,
            onLoginStatusChanged: nil,
            currentFilter: .constant("Budoucí")
        )
    }
} 
