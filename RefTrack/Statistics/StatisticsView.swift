//
//  StatisticsView.swift
//  RefTrack
//
//  Created by Michal Hájek on 25.03.2025.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                    Text("Zpět")
                }
                .foregroundColor(.blue)
                .padding(.bottom, 8)
            }
            
            HStack {
                Text("Statistiky")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Profilový obrázek
                if let profileImage = UserDefaults.standard.string(forKey: "userProfileImage") {
                    AsyncImage(url: URL(string: "http://10.0.0.15/reftrack/auth/images/\(profileImage)")) { phase in
                        switch phase {
                        case .empty:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                        @unknown default:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                        }
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom)
            
            // Bento grid layout
            Grid(horizontalSpacing: 15, verticalSpacing: 15) {
                GridRow {
                    StatCard(title: "Celkem zápasů", 
                            value: "7h 35m",
                            subtitle: "22:35 - 6:10",
                            color: .blue)
                    
                    StatCard(title: "Kroky", 
                            value: "13,046",
                            subtitle: "Start: 10:45",
                            color: .red)
                }
                
                GridRow {
                    StatCard(title: "Nálada",
                            value: "Příjemná",
                            color: .indigo)
                        .gridCellColumns(2)
                }
                
                GridRow {
                    StatCard(title: "Aktivní energie",
                            value: "465 kcal",
                            subtitle: "Start: 11:15",
                            color: .orange)
                    
                    StatCard(title: "Okysličení",
                            value: "99%",
                            color: .purple)
                }
            }
            .padding(.top)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    StatisticsView()
}

// Přidejte tuto pomocnou view pro karty
struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Přidání šipky do pravého dolního rohu
            HStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

