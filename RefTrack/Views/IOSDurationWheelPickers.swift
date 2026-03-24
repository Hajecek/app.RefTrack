//
//  IOSDurationWheelPickers.swift
//  RefTrack
//
//  Nativní výběr délky jako u systémového Časovače — dvě kola (minuty + sekundy).
//

import SwiftUI

struct IOSDurationWheelPickers: View {
    @Binding var totalSeconds: Int
    let minTotal: Int
    let maxTotal: Int

    @State private var minutes: Int = 0
    @State private var seconds: Int = 0

    private var maxMinutesComponent: Int {
        maxTotal / 60
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                Picker("Minuty", selection: $minutes) {
                    ForEach(0 ... maxMinutesComponent, id: \.self) { value in
                        Text("\(value)")
                            .monospacedDigit()
                            .tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()

                Picker("Sekundy", selection: $seconds) {
                    ForEach(0 ..< 60, id: \.self) { value in
                        Text(String(format: "%02d", value))
                            .monospacedDigit()
                            .tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
            }
            .frame(height: 216)

            HStack {
                Text("min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Text("sek")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 8)
        }
        .onAppear {
            syncWheelsFromBinding()
        }
        .onChange(of: totalSeconds) { _, newValue in
            syncWheelsFromBinding(for: newValue)
        }
        .onChange(of: minutes) { _, _ in
            applyWheelsToBinding()
        }
        .onChange(of: seconds) { _, _ in
            applyWheelsToBinding()
        }
    }

    private func syncWheelsFromBinding(for value: Int? = nil) {
        let raw = value ?? totalSeconds
        let clamped = min(max(raw, minTotal), maxTotal)
        let m = clamped / 60
        let s = clamped % 60
        if minutes != m { minutes = m }
        if seconds != s { seconds = s }
    }

    private func applyWheelsToBinding() {
        var combined = minutes * 60 + seconds
        combined = min(max(combined, minTotal), maxTotal)
        let m = combined / 60
        let s = combined % 60
        if minutes != m { minutes = m }
        if seconds != s { seconds = s }
        if totalSeconds != combined {
            totalSeconds = combined
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var t = 45 * 60
        var body: some View {
            Form {
                IOSDurationWheelPickers(
                    totalSeconds: $t,
                    minTotal: 15,
                    maxTotal: 7200
                )
            }
        }
    }
    return PreviewWrapper()
}
