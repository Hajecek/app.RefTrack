//
//  RefTrackMatchLiveActivity.swift
//  RefTrackLiveActivity
//

import ActivityKit
import SwiftUI
import WidgetKit

struct RefTrackMatchLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RefTrackMatchAttributes.self) { context in
            RefTrackLiveActivityLockView(state: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.headline)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(context.state.primaryTime)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let line = context.state.secondaryLine, !line.isEmpty {
                        Text(line)
                            .font(.caption2)
                            .multilineTextAlignment(.trailing)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    halftimeCountdownIfNeeded(state: context.state)
                }
            } compactLeading: {
                Image(systemName: "sportscourt.fill")
            } compactTrailing: {
                Text(context.state.primaryTime)
                    .font(.caption2.weight(.bold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }

    @ViewBuilder
    private func halftimeCountdownIfNeeded(state: RefTrackMatchAttributes.ContentState) -> some View {
        if let start = state.halftimeCountdownStart, let end = state.halftimeCountdownEnd, start < end {
            Text(timerInterval: start...end, countsDown: true)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        } else if let line = state.secondaryLine, !line.isEmpty {
            Text(line)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct RefTrackLiveActivityLockView: View {
    let state: RefTrackMatchAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(state.headline)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            if let start = state.halftimeCountdownStart, let end = state.halftimeCountdownEnd, start < end {
                Text(timerInterval: start...end, countsDown: true)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
            } else {
                Text(state.primaryTime)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }

            if let line = state.secondaryLine, !line.isEmpty {
                Text(line)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .activityBackgroundTint(Color.green.opacity(0.22))
    }
}
