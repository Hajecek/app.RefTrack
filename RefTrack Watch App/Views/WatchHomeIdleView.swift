//
//  WatchHomeIdleView.swift
//  RefTrack Watch App
//

import SwiftUI

struct WatchHomeIdleView: View {
    @EnvironmentObject private var vm: WatchMatchViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
            VStack(spacing: 12) {
                Text("RefTrack")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Button {
                    vm.beginNewMatchFlow()
                } label: {
                    Text("Nový zápas")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(.horizontal, 4)
            }
            .padding(8)
        }
        .ignoresSafeArea()
    }
}
