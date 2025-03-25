//
//  StatisticsView.swift
//  RefTrack
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
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
                
                VStack {
                    Text("Statistiky")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // Obsah statistik
                    ScrollView {
                        VStack(spacing: 16) {
                            StatisticCard(
                                title: "Celkem zápasů",
                                value: "24",
                                iconName: "sportscourt.fill"
                            )
                            
                            StatisticCard(
                                title: "Pískáno letos",
                                value: "12",
                                iconName: "calendar"
                            )
                            
                            StatisticCard(
                                title: "Odpískané hodiny",
                                value: "38",
                                iconName: "clock.fill"
                            )
                            
                            StatisticCard(
                                title: "Průměrné hodnocení",
                                value: "4.7",
                                iconName: "star.fill"
                            )
                            
                            // Zde můžete přidat další statistiky
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            })
        }
    }
}

struct StatisticCard: View {
    var title: String
    var value: String
    var iconName: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.4))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(value)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.leading)
                
                Spacer()
                
                Image(systemName: iconName)
                    .font(.system(size: 36))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.trailing)
            }
            .padding(.vertical, 16)
        }
        .frame(height: 100)
    }
}

#Preview {
    StatisticsView()
} 