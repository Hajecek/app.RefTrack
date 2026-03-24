//
//  RefTrackMatchLiveActivity.swift
//  RefTrackLiveActivity
//
//  Čas: `TimelineView` + lokální výpočet (běží i když je iPhone uspaný). Pauza: `Text(timerInterval:)`.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct RefTrackMatchLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RefTrackMatchAttributes.self) { context in
            RefTrackLiveActivityLockView(state: context.state)
        } dynamicIsland: { context in
            let look = PhaseLook(phase: context.state.engineState.phase)
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    IslandExpandedLeading(state: context.state, look: look)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    IslandExpandedTrailing(state: context.state)
                }
            } compactLeading: {
                Image(systemName: look.glyph)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(look.accentGradient)
            } compactTrailing: {
                MatchClockText(state: context.state, font: .caption2.weight(.bold), textScale: 0.45)
            } minimal: {
                Image(systemName: look.glyph)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(look.accentGradient)
            }
        }
    }
}

// MARK: - Barvy a ikony podle fáze

private struct PhaseLook {
    let glyph: String
    let accent: Color
    let accent2: Color

    var accentGradient: LinearGradient {
        LinearGradient(colors: [accent, accent2], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    init(phase: MatchPhase) {
        switch phase {
        case .readyToStart:
            glyph = "figure.soccer"
            accent = Color(red: 0.25, green: 0.52, blue: 1.0)
            accent2 = Color(red: 0.55, green: 0.35, blue: 1.0)
        case .firstHalfRunning, .secondHalfRunning:
            glyph = "timer"
            accent = Color(red: 0.1, green: 0.72, blue: 0.42)
            accent2 = Color(red: 0.25, green: 0.82, blue: 0.55)
        case .firstHalfStoppageTime, .secondHalfStoppageTime:
            glyph = "plus.circle.fill"
            accent = Color(red: 1.0, green: 0.48, blue: 0.1)
            accent2 = Color(red: 1.0, green: 0.65, blue: 0.25)
        case .halftimeBreak:
            glyph = "pause.circle.fill"
            accent = Color(red: 0.45, green: 0.38, blue: 0.95)
            accent2 = Color(red: 0.62, green: 0.4, blue: 0.98)
        case .readyForSecondHalf:
            glyph = "figure.run"
            accent = Color(red: 0.15, green: 0.75, blue: 0.88)
            accent2 = Color(red: 0.3, green: 0.55, blue: 0.98)
        case .idle, .finished:
            glyph = "sportscourt.fill"
            accent = Color.secondary
            accent2 = Color.secondary
        }
    }
}

// MARK: - Pauza = systémový interval; jinak lokální tikání

private func halftimeCountdownRange(_ engine: MatchEngineState) -> ClosedRange<Date>? {
    guard engine.phase == .halftimeBreak, let start = engine.halftimeStartedAt else { return nil }
    let end = start.addingTimeInterval(TimeInterval(engine.config.halftimeSeconds))
    guard start < end else { return nil }
    return start...end
}

private struct MatchClockText: View {
    let state: RefTrackMatchAttributes.ContentState
    var font: Font
    var textScale: CGFloat = 0.75

    var body: some View {
        if let range = halftimeCountdownRange(state.engineState) {
            Text(timerInterval: range, countsDown: true)
                .font(font)
                .monospacedDigit()
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(textScale)
        } else {
            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                let snap = MatchMirrorDisplayFormatter.snapshot(
                    state: state.engineState,
                    at: context.date,
                    distanceMeters: state.distanceMeters,
                    energyKilocalories: state.energyKilocalories
                )
                let secs = snap.phase == .halftimeBreak ? snap.halftimeRemainingSeconds : snap.mainClockSeconds
                Text(MatchMirrorTimeFormat.mmss(secs))
                    .font(font)
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(textScale)
            }
        }
    }
}

private struct MatchSecondaryText: View {
    let state: RefTrackMatchAttributes.ContentState
    var font: Font = .subheadline.weight(.semibold)

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let snap = MatchMirrorDisplayFormatter.snapshot(
                state: state.engineState,
                at: context.date,
                distanceMeters: state.distanceMeters,
                energyKilocalories: state.energyKilocalories
            )
            if let line = LiveActivitySecondaryLine.text(snap: snap) {
                Text(line)
                    .font(font)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
        }
    }
}

private struct IslandSecondaryText: View {
    let state: RefTrackMatchAttributes.ContentState

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let snap = MatchMirrorDisplayFormatter.snapshot(
                state: state.engineState,
                at: context.date,
                distanceMeters: state.distanceMeters,
                energyKilocalories: state.energyKilocalories
            )
            if let line = LiveActivitySecondaryLine.text(snap: snap) {
                Text(line)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}

// MARK: - Dynamic Island

private struct IslandExpandedLeading: View {
    let state: RefTrackMatchAttributes.ContentState
    let look: PhaseLook

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: look.glyph)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(look.accentGradient)
                Text(state.headline)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            MatchClockText(state: state, font: .title2.weight(.bold), textScale: 0.8)
        }
    }
}

private struct IslandExpandedTrailing: View {
    let state: RefTrackMatchAttributes.ContentState

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            IslandSecondaryText(state: state)
            Spacer(minLength: 0)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Lock Screen

private struct RefTrackLiveActivityLockView: View {
    let state: RefTrackMatchAttributes.ContentState

    private var look: PhaseLook { PhaseLook(phase: state.engineState.phase) }

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(look.accentGradient.opacity(0.28))
                Image(systemName: look.glyph)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(look.accentGradient)
            }
            .frame(width: 56, height: 56)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 16) {
                Text(state.headline)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.88)
                    .fixedSize(horizontal: false, vertical: true)

                MatchClockText(
                    state: state,
                    font: .system(size: 52, weight: .bold, design: .rounded),
                    textScale: 0.65
                )

                MatchSecondaryText(state: state, font: .body.weight(.semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 2)
        .activityBackgroundTint(look.accent.opacity(0.2))
    }
}
