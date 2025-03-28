//
//  StatisticsView.swift
//  RefTrack
//
//  Created by Michal Hájek on 25.03.2025.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                    Text("Zpět do dashboardu")
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
                    
                    StatCard(title: "Celkem vzdálenost", 
                            value: "13,046",
                            subtitle: "Start: 10:45",
                            color: .indigo)
                }
                
                GridRow {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Nálada")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        MoodChart()
                            .frame(height: 100)
                            .padding(.vertical, 5)
                        
                        HStack {
                            Text("Příjemná")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                    .background(Color.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .gridCellColumns(2)
                }
                
                GridRow {
                    StatCard(title: "Celkem žlutých karet",
                            value: "465 kcal",
                            subtitle: "Start: 11:15",
                            color: Color(red: 0.8, green: 0.6, blue: 0.0))
                    
                    StatCard(title: "Celkem červených karet",
                            value: "99%",
                            color: Color(red: 0.8, green: 0.0, blue: 0.0))
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

struct MoodChart: View {
    let data: [Double] = [3, 4, 5, 4, 3, 4, 5] // Hodnoty nálady (1-5)
    
    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Den", index),
                    y: .value("Nálada", value)
                )
                .interpolationMethod(.catmullRom) // Hladší křivka
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .foregroundStyle(.white)
                
                PointMark(
                    x: .value("Den", index),
                    y: .value("Nálada", value)
                )
                .symbolSize(15) // Zvýraznění bodů
                .foregroundStyle(.white)
                
                AreaMark(
                    x: .value("Den", index),
                    y: .value("Nálada", value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0.2), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartYScale(domain: 1...5) // Fixní rozsah pro náladu
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                AxisGridLine()
                    .foregroundStyle(.white.opacity(0.2))
                AxisTick()
                    .foregroundStyle(.white)
                AxisValueLabel()
                    .foregroundStyle(.white)
            }
        }
        .frame(height: 100)
        .padding(.horizontal, 5)
    }
}

struct OxygenChart: View {
    let data: [Double] = [98, 99, 98, 99, 98, 99, 98]
    
    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Den", index),
                    y: .value("Okysličení", value)
                )
                .foregroundStyle(.white)
                
                AreaMark(
                    x: .value("Den", index),
                    y: .value("Okysličení", value)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0.1), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 100)
    }
}

