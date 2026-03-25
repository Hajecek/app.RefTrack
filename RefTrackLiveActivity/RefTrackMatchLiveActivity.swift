//
//  RefTrackMatchLiveActivity.swift
//  RefTrackLiveActivity
//
//  iOS-like redesign: systémové barvy, typografie SF, activityBackgroundTint, jemný progress.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct RefTrackMatchLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RefTrackMatchAttributes.self) { context in
            LockScreenLiveActivityView(state: context.state)
                .tint(.accentColor)
                .activityBackgroundTint(.clear) // nechte systém řídit podklad (Always-On, tapety)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeading(state: context.state)
                }
                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenter(state: context.state)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailing(state: context.state)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottom(state: context.state)
                }
            } compactLeading: {
                CompactLeadingIcon(state: context.state)
            } compactTrailing: {
                CompactTrailingTime(state: context.state)
            } minimal: {
                MinimalIcon(state: context.state)
            }
        }
    }
}

// MARK: - Pomocné výpočty

private enum MatchJourneyProgress {
    static func value(engine: MatchEngineState, snap: MatchDisplaySnapshot) -> CGFloat {
        let H = max(1, engine.config.halfLengthSeconds)
        let totalReg = CGFloat(H * 2)
        let mc = CGFloat(snap.mainClockSeconds)

        switch snap.phase {
        case .firstHalfRunning:
            return min(0.5, max(0, mc / totalReg))
        case .firstHalfStoppageTime, .readyForSecondHalf:
            return 0.5
        case .halftimeBreak:
            let ht = max(1, engine.config.halftimeSeconds)
            let elapsed = CGFloat(ht - snap.halftimeRemainingSeconds)
            // malý posun během pauzy (max ~8 % šířky)
            return 0.5 + min(0.08, (elapsed / CGFloat(ht)) * 0.08)
        case .secondHalfRunning:
            return min(1, max(0.5, mc / totalReg))
        case .secondHalfStoppageTime, .finished:
            return 1
        case .readyToStart, .idle:
            return 0
        }
    }
}

private func halftimeCountdownRange(_ engine: MatchEngineState) -> ClosedRange<Date>? {
    guard engine.phase == .halftimeBreak, let start = engine.halftimeStartedAt else { return nil }
    let end = start.addingTimeInterval(TimeInterval(engine.config.halftimeSeconds))
    guard start < end else { return nil }
    return start...end
}

// MARK: - Společné prvky

private struct HeadlineLabel: View {
    let state: RefTrackMatchAttributes.ContentState

    private var phaseText: String {
        switch state.engineState.phase {
        case .idle: return "RefTrack"
        case .readyToStart: return "Připraveno"
        case .firstHalfRunning: return "1. poločas"
        case .firstHalfStoppageTime: return "1. poločas · nastavení"
        case .halftimeBreak: return "Poločas"
        case .readyForSecondHalf: return "Před 2. poločasem"
        case .secondHalfRunning: return "2. poločas"
        case .secondHalfStoppageTime: return "2. poločas · nastavení"
        case .finished: return "Konec"
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sportscourt.fill")
                .imageScale(.medium)
                .foregroundStyle(.tint)
            Text(phaseText.uppercased())
                .font(.caption.weight(.semibold))
                .textCase(.none)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(phaseText)
    }
}

private struct MatchClockText: View {
    let state: RefTrackMatchAttributes.ContentState
    var font: Font
    var textScale: CGFloat = 0.85
    var foreground: Color = .primary

    var body: some View {
        Group {
            if let range = halftimeCountdownRange(state.engineState) {
                Text(timerInterval: range, countsDown: true)
                    .font(font)
                    .monospacedDigit()
                    .foregroundStyle(foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(textScale)
                    .contentTransition(.numericText())
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
                        .foregroundStyle(foreground)
                        .lineLimit(1)
                        .minimumScaleFactor(textScale)
                        .contentTransition(.numericText())
                }
            }
        }
        .accessibilityLabel("Čas")
    }
}

private struct SegmentSecondaryLine: View {
    let state: RefTrackMatchAttributes.ContentState
    var font: Font = .footnote

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            Text(segmentSecondaryCopy(state: state, at: context.date))
                .font(font)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    private func segmentSecondaryCopy(state: RefTrackMatchAttributes.ContentState, at date: Date) -> String {
        let snap = MatchMirrorDisplayFormatter.snapshot(
            state: state.engineState,
            at: date,
            distanceMeters: state.distanceMeters,
            energyKilocalories: state.energyKilocalories
        )
        if snap.isStoppageActive {
            return "Nastavení \(MatchMirrorTimeFormat.mmss(snap.stoppageSeconds))"
        }
        if state.engineState.phase == .halftimeBreak {
            return "Pauza \(MatchMirrorTimeFormat.mmss(snap.halftimeRemainingSeconds))"
        }
        let total = totalSecondsForSegment(state.engineState)
        return "Celkem \(MatchMirrorTimeFormat.mmss(total))"
    }

    private func totalSecondsForSegment(_ engine: MatchEngineState) -> Int {
        switch engine.phase {
        case .halftimeBreak:
            return max(1, engine.config.halftimeSeconds)
        default:
            return max(1, engine.config.halfLengthSeconds)
        }
    }
}

private struct JourneyProgressBarFill: View {
    let progress: CGFloat
    var height: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let clamped = min(1, max(0, progress))
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.primary.opacity(0.12))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.55)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(height, w * clamped))
            }
        }
        .frame(height: height)
    }
}

private struct JourneyProgressBar: View {
    let state: RefTrackMatchAttributes.ContentState
    var height: CGFloat = 4

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let snap = MatchMirrorDisplayFormatter.snapshot(
                state: state.engineState,
                at: context.date,
                distanceMeters: state.distanceMeters,
                energyKilocalories: state.energyKilocalories
            )
            let p = MatchJourneyProgress.value(engine: state.engineState, snap: snap)
            JourneyProgressBarFill(progress: p, height: height)
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Lock Screen UI

private struct LockScreenLiveActivityView: View {
    let state: RefTrackMatchAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HeadlineLabel(state: state)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                MatchClockText(
                    state: state,
                    font: .system(.title, design: .rounded).weight(.bold),
                    textScale: 0.6
                )
                Spacer(minLength: 8)
                SegmentSecondaryLine(state: state, font: .subheadline)
            }

            JourneyProgressBar(state: state, height: 4)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
    }
}

// MARK: - Dynamic Island: Expanded

private struct ExpandedLeading: View {
    let state: RefTrackMatchAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HeadlineLabel(state: state)
            MatchClockText(
                state: state,
                font: .system(.title2, design: .rounded).weight(.bold),
                textScale: 0.7
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ExpandedCenter: View {
    let state: RefTrackMatchAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SegmentSecondaryLine(state: state, font: .footnote)
            JourneyProgressBar(state: state, height: 3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ExpandedTrailing: View {
    let state: RefTrackMatchAttributes.ContentState

    private var rightBadge: some View {
        Group {
            switch state.engineState.phase {
            case .firstHalfStoppageTime, .secondHalfStoppageTime:
                Label("Nastavení", systemImage: "plus.forwardslash.minus")
            case .halftimeBreak:
                Label("Pauza", systemImage: "pause.fill")
            case .finished:
                Label("Konec", systemImage: "flag.checkered")
            default:
                Label("Běží", systemImage: "figure.run")
            }
        }
        .labelStyle(.iconOnly)
        .foregroundStyle(.tint)
        .imageScale(.medium)
        .accessibilityLabel("Stav zápasu")
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            rightBadge
            if let range = halftimeCountdownRange(state.engineState) {
                Text(timerInterval: range, countsDown: true)
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Text(MatchMirrorTimeFormat.formatDistanceMeters(state.distanceMeters))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

private struct ExpandedBottom: View {
    let state: RefTrackMatchAttributes.ContentState

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
                .imageScale(.small)
            Text("\(Int(state.energyKilocalories)) kcal")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()

            Image(systemName: "ruler")
                .foregroundStyle(.tint)
                .imageScale(.small)
            Text(MatchMirrorTimeFormat.formatDistanceMeters(state.distanceMeters))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }
}

// MARK: - Dynamic Island: Compact & Minimal

private struct CompactLeadingIcon: View {
    let state: RefTrackMatchAttributes.ContentState
    var body: some View {
        Image(systemName: "sportscourt.fill")
            .foregroundStyle(.tint)
            .imageScale(.small)
            .accessibilityHidden(true)
    }
}

private struct CompactTrailingTime: View {
    let state: RefTrackMatchAttributes.ContentState
    var body: some View {
        MatchClockText(
            state: state,
            font: .caption2.weight(.bold),
            textScale: 0.55
        )
        .foregroundStyle(.primary)
    }
}

private struct MinimalIcon: View {
    let state: RefTrackMatchAttributes.ContentState
    var body: some View {
        Image(systemName: minimalSymbol(for: state.engineState.phase))
            .foregroundStyle(.tint)
            .imageScale(.small)
            .accessibilityHidden(true)
    }

    private func minimalSymbol(for phase: MatchPhase) -> String {
        switch phase {
        case .firstHalfStoppageTime, .secondHalfStoppageTime: return "plus.forwardslash.minus"
        case .halftimeBreak: return "pause.fill"
        case .finished: return "flag.checkered"
        default: return "sportscourt.fill"
        }
    }
}

