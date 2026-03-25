//
//  RefTrackMatchLiveActivity.swift
//  RefTrackLiveActivity
//
//  Čas nepoužívá TimelineView.periodic (ve widgetech často přestane tikat) — systémové Text(timerInterval) / .timer.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct RefTrackMatchLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RefTrackMatchAttributes.self) { context in
            LockScreenLiveActivityView(state: context.state)
                .tint(.accentColor)
                .activityBackgroundTint(.clear)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    ExpandedIslandCenter(state: context.state)
                }
            } compactLeading: {
                CompactLeadingIcon(state: context.state)
            } compactTrailing: {
                CompactTrailingTime(state: context.state)
            } minimal: {
                MinimalIslandIcon(state: context.state)
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

// MARK: - Pomocné funkce pro Dynamic Island

private func phaseTitle(for phase: MatchPhase) -> String {
    switch phase {
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

private func phaseSymbol(for phase: MatchPhase) -> String {
    switch phase {
    case .firstHalfStoppageTime, .secondHalfStoppageTime:
        return "plus.forwardslash.minus"
    case .halftimeBreak:
        return "pause.fill"
    case .finished:
        return "flag.checkered"
    default:
        return "sportscourt.fill"
    }
}

private func compactTimeString(state: RefTrackMatchAttributes.ContentState) -> String {
    let snap = MatchMirrorDisplayFormatter.snapshot(
        state: state.engineState,
        at: Date(),
        distanceMeters: state.distanceMeters,
        energyKilocalories: state.energyKilocalories
    )

    let secs: Int
    switch snap.phase {
    case .halftimeBreak:
        secs = snap.halftimeRemainingSeconds
    default:
        secs = snap.mainClockSeconds
    }

    return MatchMirrorTimeFormat.mmss(secs)
}

// MARK: - Společné prvky

private struct HeadlineLabel: View {
    let state: RefTrackMatchAttributes.ContentState

    private var phaseText: String {
        phaseTitle(for: state.engineState.phase)
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
            } else if state.engineState.phase == .firstHalfRunning, let t0 = state.engineState.firstHalfStartedAt {
                let half = TimeInterval(state.engineState.config.halfLengthSeconds)
                let end = t0.addingTimeInterval(half)
                Text(timerInterval: t0...end, countsDown: false)
                    .font(font)
                    .monospacedDigit()
                    .foregroundStyle(foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(textScale)
                    .contentTransition(.numericText())
            } else if state.engineState.phase == .secondHalfRunning, let t2 = state.engineState.secondHalfStartedAt {
                let half = TimeInterval(state.engineState.config.halfLengthSeconds)
                let virtualStart = t2.addingTimeInterval(-half)
                Text(virtualStart, style: .timer)
                    .font(font)
                    .monospacedDigit()
                    .foregroundStyle(foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(textScale)
                    .contentTransition(.numericText())
            } else {
                clockTextStaticSnapshot
            }
        }
        .accessibilityLabel("Čas")
    }

    private var clockTextStaticSnapshot: some View {
        let snap = MatchMirrorDisplayFormatter.snapshot(
            state: state.engineState,
            at: Date(),
            distanceMeters: state.distanceMeters,
            energyKilocalories: state.energyKilocalories
        )
        let secs = snap.phase == .halftimeBreak ? snap.halftimeRemainingSeconds : snap.mainClockSeconds

        return Text(MatchMirrorTimeFormat.mmss(secs))
            .font(font)
            .monospacedDigit()
            .foregroundStyle(foreground)
            .lineLimit(1)
            .minimumScaleFactor(textScale)
            .contentTransition(.numericText())
    }
}

private struct SegmentSecondaryLine: View {
    let state: RefTrackMatchAttributes.ContentState
    var font: Font = .footnote

    var body: some View {
        Group {
            if state.engineState.phase == .firstHalfStoppageTime,
               let stop = state.engineState.firstStoppageStartedAt {
                HStack(spacing: 4) {
                    Text("Nastavení")
                    Text(timerInterval: stop...stop.addingTimeInterval(3600 * 3), countsDown: false)
                }
                .font(font)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            } else if state.engineState.phase == .secondHalfStoppageTime,
                      let stop = state.engineState.secondStoppageStartedAt {
                HStack(spacing: 4) {
                    Text("Nastavení")
                    Text(timerInterval: stop...stop.addingTimeInterval(3600 * 3), countsDown: false)
                }
                .font(font)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            } else if let range = halftimeCountdownRange(state.engineState) {
                HStack(spacing: 4) {
                    Text("Pauza")
                    Text(timerInterval: range, countsDown: true)
                }
                .font(font)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            } else {
                Text(segmentSecondaryCopyStatic(state: state))
                    .font(font)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }

    private func segmentSecondaryCopyStatic(state: RefTrackMatchAttributes.ContentState) -> String {
        let snap = MatchMirrorDisplayFormatter.snapshot(
            state: state.engineState,
            at: Date(),
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
        TimelineView(.animation(minimumInterval: 1.0)) { context in
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

private struct ExpandedIslandCenter: View {
    let state: RefTrackMatchAttributes.ContentState

    private var title: String {
        phaseTitle(for: state.engineState.phase)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            MatchClockText(
                state: state,
                font: .system(size: 34, weight: .semibold, design: .rounded),
                textScale: 0.75,
                foreground: .primary
            )
        }
        .multilineTextAlignment(.center)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Dynamic Island: Compact & Minimal

private struct CompactLeadingIcon: View {
    let state: RefTrackMatchAttributes.ContentState

    var body: some View {
        Image(systemName: phaseSymbol(for: state.engineState.phase))
            .foregroundStyle(.tint)
            .imageScale(.small)
            .accessibilityHidden(true)
    }
}

private struct CompactTrailingTime: View {
    let state: RefTrackMatchAttributes.ContentState

    var body: some View {
        Text("ČAS")
            .font(.caption2.weight(.bold))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(.primary)
            .accessibilityLabel("Čas")
    }
}

private struct MinimalIslandIcon: View {
    let state: RefTrackMatchAttributes.ContentState

    var body: some View {
        // Minimal slot používáme bez textového času, protože některé kombinace UI mohou přestat průběžně aktualizovat.
        // Pravá strana je jen statická ikona, aby ostrov vypadal vyplněně.
        HStack(spacing: 4) {
            Image(systemName: phaseSymbol(for: state.engineState.phase))
                .foregroundStyle(.tint)
                .imageScale(.small)

            Image(systemName: "clock.fill")
                .foregroundStyle(.secondary)
                .imageScale(.small)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(phaseTitle(for: state.engineState.phase))
    }
}