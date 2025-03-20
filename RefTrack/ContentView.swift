//
//  ContentView.swift
//  RefTrack
//
//  Created by Michal Hájek on 19.03.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showLoginView = false
    
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
                // Horní panel
                HStack(alignment: .center) {
                    Text("Nadcházející")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // Akce pro přidání
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 2)
                    
                    Button(action: {
                        // Akce pro profil
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .frame(height: 60)
                
                Spacer()
                
                // Obsah pro prázdný stav
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
                    .sheet(isPresented: $showLoginView) {
                        LoginView()
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
