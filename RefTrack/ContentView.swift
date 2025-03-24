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
    
    init() {
        // Nastavíme výchozí filtr podle stavu přihlášení
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        _currentFilter = State(initialValue: isLoggedIn ? "Nadcházející" : "Veřejné")
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
                        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                        // Pokud se uživatel přihlásí, změníme filtr na "Nadcházející"
                        if isLoggedIn {
                            currentFilter = "Nadcházející"
                        } else {
                            currentFilter = "Veřejné"
                        }
                    },
                    currentFilter: $currentFilter
                )
                
                Spacer()
                
                if !isLoggedIn && currentFilter != "Veřejné" {
                    // Obsah pro nepřihlášeného uživatele (pouze pro jiné filtry než "Veřejné")
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
                } else {
                    // Obsah podle vybraného filtru (pro přihlášené uživatele nebo filtr "Veřejné")
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
                            Text("Zde uvidíte své plánované nadcházející události.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 40)
                        case "Předchozí":
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 60))
                                .foregroundColor(.purple)
                            Text("Předchozí")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Přehled událostí, které už skončily.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 40)
                        case "Probíhá":
                            Image(systemName: "pencil")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            Text("Právě se děje")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Události, které jsou právě Live.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 40)
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
                                .padding(.horizontal, 40)
                        case "Veřejné":
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            Text("Veřejné události")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Události, které ostatní uživatelé označili za veřejné.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 40)
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
                                .padding(.horizontal, 40)
                        }
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
            isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            if !isLoggedIn {
                currentFilter = "Veřejné"
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoginStatusChanged"))) { _ in
            isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            // Při přihlášení změníme filtr na "Nadcházející"
            if isLoggedIn {
                currentFilter = "Nadcházející"
            } else {
                currentFilter = "Veřejné"
            }
        }
    }
}

#Preview {
    ContentView()
}
