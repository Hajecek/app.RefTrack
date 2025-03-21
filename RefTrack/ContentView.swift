//
//  ContentView.swift
//  RefTrack
//
//  Created by Michal Hájek on 19.03.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showLoginView = false
    @State private var isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var currentFilter = "Nadcházející"
    
    var body: some View {
        ZStack {
            // Rozmazané pozadí s barvami podobnými obrázku
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.15, green: 0.2, blue: 0.35), // Světlejší modrá nahoře
                    Color(red: 0.1, green: 0.15, blue: 0.25), // Tmavší modrá uprostřed
                    Color(red: 0.15, green: 0.15, blue: 0.2), // Tmavá přechodová
                    Color(red: 0.3, green: 0.25, blue: 0.15).opacity(0.7) // Zlatavá dole
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .blur(radius: 1.5)
            
            // Tmavý overlay pro lepší kontrast
            Color.black.opacity(0.15)
                .ignoresSafeArea()
            
            // Zaoblený rámeček pro obsah
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.black.opacity(0.4))
                .padding(.horizontal, 16)
                .padding(.top, 120)
                .padding(.bottom, 40)
                .blur(radius: 0.5)
            
            VStack {
                // Horní panel - nyní použijeme vlastní komponentu s profilovým obrázkem
                TopMenuBar(
                    onAddTap: {
                        // Akce pro přidání
                    },
                    onProfileTap: {
                        // Akce pro profil
                    },
                    isLoggedIn: isLoggedIn,
                    profileImage: UserDefaults.standard.string(forKey: "userProfileImage"),
                    onLoginStatusChanged: {
                        // Aktualizace stavu přihlášení v ContentView
                        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                    },
                    currentFilter: $currentFilter
                )
                
                Spacer()
                
                if isLoggedIn {
                    // Obsah pro přihlášeného uživatele podle vybraného filtru
                    VStack(spacing: 20) {
                        switch currentFilter {
                        case "Nadcházející":
                            Image(systemName: "calendar")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            Text("Nadcházející události")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Zde uvidíte své plánované události.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        case "Předchozí":
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 60))
                                .foregroundColor(.purple)
                            Text("Předchozí")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Přehled událostí, kterých jste se již zúčastnili.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        case "Koncepty":
                            Image(systemName: "pencil")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            Text("Vaše koncepty")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Rozpracované události čekající na dokončení.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        case "Pořádám":
                            Image(systemName: "crown")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)
                            Text("Pořádané události")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Seznam událostí, které organizujete.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        case "Zúčastním se":
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            Text("Události s vaší účastí")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Události, na které jste potvrdili svou účast.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        default:
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            Text("Jste přihlášeni")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Nyní můžete přidávat a zobrazovat události.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .padding(.top, 20)
                } else {
                    // Obsah pro nepřihlášeného uživatele
                    VStack(spacing: 20) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Přihlaste se")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Pro přidání a zobrazení událostí se musíte nejprve přihlásit.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            showLoginView = true
                        }) {
                            Text("Přihlásit se")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .frame(width: 250)
                                .background(Color.white)
                                .cornerRadius(30)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                    .padding(.top, 20)
                }
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showLoginView) {
            LoginView()
                .onDisappear {
                    // Kontrola stavu přihlášení při zavření přihlašovacího okna
                    isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                }
        }
        .onAppear {
            // Zkontrolujeme stav přihlášení při zobrazení
            isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoginStatusChanged"))) { _ in
            // Aktualizace stavu přihlášení při přijetí notifikace
            isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        }
    }
}

#Preview {
    ContentView()
}
