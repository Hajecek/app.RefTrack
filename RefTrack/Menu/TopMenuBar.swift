//
//  TopMenuBar.swift
//  RefTrack
//

import SwiftUI

struct TopMenuBar: View {
    var onAddTap: () -> Void
    var onProfileTap: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            Text("Nadcházející")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: onAddTap) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            .padding(.trailing, 2)
            
            Button(action: onProfileTap) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
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
            onProfileTap: {}
        )
    }
} 