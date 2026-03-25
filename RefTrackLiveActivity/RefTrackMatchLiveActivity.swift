//
//  RefTrackMatchLiveActivity.swift
//  RefTrackLiveActivity
//
//  Rozvržení inspirované „BOLT“: tmavá karta, logo + název, čas / pod-čas, gradient bar.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct RefTrackMatchLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RefTrackMatchAttributes.self) { context in
            RefTrackLiveActivityLockView(state: context.state)
        } dynamicIsland: { context in
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    IslandExpandedCard(state: context.state)
                }
            } compactLeading: {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LivePalette.brandOrange)
            } compactTrailing: {
                MatchClockText(
                    state: context.state,
                    font: .caption.weight(.bold),
                    textScale: 0.55,
                    foreground: .primary
                )
            } minimal: {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LivePalette.brandOrange)
            }
        }
    }
}

// MARK: - Paleta (tmavá karta jako na referenci)

private enum LivePalette {
    static let cardBackground = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let trackGray = Color(white: 0.22)
    static let subtext = Color(white: 0.45)
    static let brandOrange = Color(red: 1.0, green: 0.48, blue: 0.12)
    static let barGradientEnd = Color(red: 1.0, green: 0.28, blue: 0.2)

    static var barGradient: LinearGradient {
        LinearGradient(
            colors: [brandOrange, barGradientEnd],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Progress 0…1

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

// MARK: - Čas

private struct MatchClockText: View {
    let state: RefTrackMatchAttributes.ContentState
    var font: Font
    var textScale: CGFloat = 0.75
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
                        .contentTransition(.numericText())
                        .lineLimit(1)
                        .minimumScaleFactor(textScale)
                }
            }
        }
    }
}

/// Druhý řádek: délka segmentu (poločas / pauza) jako na referenci „01:30“ pod hlavním časem.
private struct SegmentTotalText: View {
    let state: RefTrackMatchAttributes.ContentState
    var font: Font

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { _ in
            let total = totalSecondsForSegment(state.engineState)
            Text(MatchMirrorTimeFormat.mmss(total))
                .font(font)
                .monospacedDigit()
                .foregroundStyle(LivePalette.subtext)
        }
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

// MARK: - Progress bar (oranžovo-červený gradient)

private struct JourneyProgressBar: View {
    let state: RefTrackMatchAttributes.ContentState
    var height: CGFloat = 6

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let snap = MatchMirrorDisplayFormatter.snapshot(
                state: state.engineState,
                at: context.date,
                distanceMeters: state.distanceMeters,
                energyKilocalories: state.energyKilocalories
            )
            let p = MatchJourneyProgress.value(engine: state.engineState, snap: snap)
            GeometryReader { geo in
                let w = geo.size.width
                let clamped = min(1, max(0, p))
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(LivePalette.trackGray)
                    Capsule()
                        .fill(LivePalette.barGradient)
                        .frame(width: max(height, w * clamped))
                }
            }
            .frame(height: height)
        }
    }
}

// MARK: - Sdílený obsah karty

private struct LiveActivityCardContent: View {
    let state: RefTrackMatchAttributes.ContentState
    var primaryTimeSize: CGFloat
    var secondaryTimeSize: CGFloat
    var headerIconSize: CGFloat
    var sectionSpacing: CGFloat
    var horizontalPadding: CGFloat

    var body: some View {
        VStack(spacing: sectionSpacing) {
            HStack(spacing: 8) {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: headerIconSize, weight: .semibold))
                    .foregroundStyle(LivePalette.brandOrange)
                Text("REFTRACK")
                    .font(.system(size: headerIconSize + 1, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 6) {
                MatchClockText(
                    state: state,
                    font: .system(size: primaryTimeSize, weight: .bold, design: .rounded),
                    textScale: 0.62,
                    foreground: .white
                )
                SegmentTotalText(
                    state: state,
                    font: .system(size: secondaryTimeSize, weight: .semibold, design: .rounded)
                )
            }
            .frame(maxWidth: .infinity)

            JourneyProgressBar(state: state, height: max(5, primaryTimeSize * 0.12))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, horizontalPadding * 0.85)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LivePalette.cardBackground)
        }
    }
}

// MARK: - Dynamic Island rozšířený

private struct IslandExpandedCard: View {
    let state: RefTrackMatchAttributes.ContentState

    var body: some View {
        LiveActivityCardContent(
            state: state,
            primaryTimeSize: 26,
            secondaryTimeSize: 15,
            headerIconSize: 11,
            sectionSpacing: 12,
            horizontalPadding: 14
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Lock Screen

private struct RefTrackLiveActivityLockView: View {
    let state: RefTrackMatchAttributes.ContentState

    var body: some View {
        LiveActivityCardContent(
            state: state,
            primaryTimeSize: 52,
            secondaryTimeSize: 22,
            headerIconSize: 14,
            sectionSpacing: 18,
            horizontalPadding: 20
        )
        .activityBackgroundTint(Color.black.opacity(0.35))
    }
}
