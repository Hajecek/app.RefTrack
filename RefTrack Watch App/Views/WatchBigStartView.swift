//
//  WatchBigStartView.swift
//  RefTrack Watch App
//

import SwiftUI

struct WatchBigStartView: View {
    @EnvironmentObject private var vm: WatchMatchViewModel

    var body: some View {
        ZStack {
            Color.green.opacity(0.92)
            Text("START")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(.black)
                .minimumScaleFactor(0.5)
        }
        .contentShape(Rectangle())
        .ignoresSafeArea()
        .onTapGesture {
            vm.startMatchFromReadyScreen()
        }
    }
}
