//
//  WatchSecondHalfGateView.swift
//  RefTrack Watch App
//

import SwiftUI

struct WatchSecondHalfGateView: View {
    @EnvironmentObject private var vm: WatchMatchViewModel

    var body: some View {
        ZStack {
            Color.teal.opacity(0.9)
            Text("POKRAČOVAT NA 2. POLOČAS")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(8)
        }
        .contentShape(Rectangle())
        .ignoresSafeArea()
        .onTapGesture {
            vm.startSecondHalfFromIntro()
        }
    }
}
