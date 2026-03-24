//
//  MatchDurationEditorView.swift
//  RefTrack
//
//  Samostatná obrazovka s koly — mimo Form, aby se layout nerozbíjel.
//

import SwiftUI

struct MatchDurationEditorView: View {
    let navigationTitle: String
    let footerText: String
    @Binding var totalSeconds: Int
    let minTotal: Int
    let maxTotal: Int

    var body: some View {
        VStack(spacing: 20) {
            Text(MatchDurationFormat.describe(seconds: totalSeconds))
                .font(.title.weight(.bold))
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .padding(.top, 16)

            IOSDurationWheelPickers(
                totalSeconds: $totalSeconds,
                minTotal: minTotal,
                maxTotal: maxTotal
            )
            .padding(.horizontal, 8)

            Text(footerText)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MatchDurationEditorView(
            navigationTitle: "Poločas",
            footerText: "Minimum 15 s, maximum 2 hodiny.",
            totalSeconds: .constant(45 * 60),
            minTotal: 15,
            maxTotal: 7200
        )
    }
}
