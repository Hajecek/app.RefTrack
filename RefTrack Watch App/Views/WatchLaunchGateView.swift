//
//  WatchLaunchGateView.swift
//  RefTrack Watch App
//

import SwiftUI

struct WatchLaunchGateView: View {
    @ObservedObject private var wcSession = WatchWCSession.shared

    @State private var isReady = false
    @State private var launchStartedAt: Date?

    private let minSplashSeconds: TimeInterval = 1.15
    private let maxSplashSeconds: TimeInterval = 2.4

    var body: some View {
        ZStack {
            if isReady {
                ContentView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                WatchLaunchScreenView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isReady)
        .onChange(of: wcSession.activationState) { newState in
            guard newState == .activated else { return }
            scheduleReadyAfterMinSplash()
        }
        .task {
            launchStartedAt = launchStartedAt ?? Date()

            if wcSession.activationState == .activated {
                scheduleReadyAfterMinSplash()
            }

            // Fallback: nezasekne se to, když spojení z nějakého důvodu neproběhne.
            try? await Task.sleep(nanoseconds: UInt64(maxSplashSeconds * 1_000_000_000))
            await MainActor.run {
                scheduleReadyAfterMinSplash(force: true)
            }
        }
    }

    private func scheduleReadyAfterMinSplash(force: Bool = false) {
        guard !isReady else { return }

        if launchStartedAt == nil {
            launchStartedAt = Date()
        }

        let elapsed = Date().timeIntervalSince(launchStartedAt ?? Date())
        let remaining = minSplashSeconds - elapsed
        guard force || remaining <= 0 else {
            let delay = max(0, remaining)
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                withAnimation(.easeInOut(duration: 0.25)) { isReady = true }
            }
            return
        }

        withAnimation(.easeInOut(duration: 0.25)) { isReady = true }
    }
}

private struct WatchLaunchScreenView: View {
    @State private var animateIn = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.green.opacity(0.22),
                    Color.mint.opacity(0.18),
                    Color.blue.opacity(0.16),
                    Color.black.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white.opacity(0.92))
                    .symbolRenderingMode(.hierarchical)
                    .scaleEffect(animateIn ? 1.0 : 0.85)
                    .opacity(animateIn ? 1.0 : 0.0)
                    .rotationEffect(.degrees(animateIn ? 0 : -7))
                    .animation(.spring(response: 0.55, dampingFraction: 0.78), value: animateIn)

                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.2)
                    .opacity(animateIn ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.35).delay(0.12), value: animateIn)

                Text("Načítání...")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))
                    .opacity(animateIn ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.35).delay(0.08), value: animateIn)

                Text("RefTrack")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .opacity(animateIn ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.35).delay(0.14), value: animateIn)
            }
        }
        .onAppear {
            animateIn = true
        }
    }
}

