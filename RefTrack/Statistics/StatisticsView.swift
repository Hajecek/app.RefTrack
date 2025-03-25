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
            
            Text("Statistiky")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
            
            Spacer()
            
            Text("Obsah statistik bude zde")
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    StatisticsView()
}

