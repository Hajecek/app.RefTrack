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
    @State private var currentFilter: String
    @State private var hasPublicMatches = false
    
    init() {
        // Nastavíme výchozí filtr podle stavu přihlášení
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        _currentFilter = State(initialValue: isLoggedIn ? "Budoucí" : "Veřejné")
    }
    
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
            
            // Zaoblený rámeček pro obsah - nyní podmíněně
            if currentFilter != "Veřejné" || !hasPublicMatches {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black.opacity(0.4))
                    .padding(.horizontal, 16)
                    .padding(.top, 120)
                    .padding(.bottom, 40)
                    .blur(radius: 0.5)
            }
            
            VStack {
                // Horní panel - nyní použijeme vlastní komponentu s profilovým obrázkem
                TopMenuBar(
                    onAddTap: {
                        // Akce pro přidání
                    },
                    onProfileTap: {
                        // Akce pro profil
                    },
                    onStatsTap: {
                        // Akce pro statistiky
                    },
                    isLoggedIn: isLoggedIn,
                    profileImage: UserDefaults.standard.string(forKey: "userProfileImage"),
                    onLoginStatusChanged: {
                        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                        if isLoggedIn {
                            currentFilter = "Budoucí"
                        } else {
                            currentFilter = "Veřejné"
                        }
                    },
                    currentFilter: $currentFilter
                )
                
                Spacer()
                
                if !isLoggedIn && currentFilter != "Veřejné" {
                    // Obsah pro nepřihlášeného uživatele (pouze pro jiné filtry než "Veřejné")
                    EventView(
                        iconName: "lock.fill",
                        iconColor: .gray,
                        title: "Přihlaste se",
                        description: "Pro přidání a zobrazení událostí se musíte nejprve přihlásit."
                    )
                    
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
                } else {
                    // Obsah podle vybraného filtru
                    switch currentFilter {
                    case "Veřejné":
                        PublicEventsView(hasMatches: $hasPublicMatches)
                    default:
                        // Pro všechny ostatní případy zachováme původní vzhled
                        switch currentFilter {
                        case "Budoucí":
                            UpcomingEventsView()
                        case "Předchozí":
                            PastEventsView()
                        case "Probíhá":
                            LiveEventsView()
                        case "Pořádám":
                            OrganizedEventsView()
                        default:
                            EventView(
                                iconName: "checkmark.circle.fill",
                                iconColor: .green,
                                title: "Jste přihlášeni",
                                description: "Nyní můžete přidávat a zobrazovat události."
                            )
                        }
                    }
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
            isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            if !isLoggedIn {
                currentFilter = "Veřejné"
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoginStatusChanged"))) { _ in
            isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            // Při přihlášení změníme filtr na "Nadcházející"
            if isLoggedIn {
                currentFilter = "Budoucí"
            } else {
                currentFilter = "Veřejné"
            }
        }
    }
}

#Preview {
    ContentView()
}
