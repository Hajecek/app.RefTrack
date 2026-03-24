//
//  MatchPhase.swift
//  RefTrack Watch App
//

import Foundation

/// Stavový automat zápasu — fáze musí odpovídat přechodům v `MatchTimerEngine`.
enum MatchPhase: String, Codable, CaseIterable, Sendable {
    case idle
    case readyToStart
    case firstHalfRunning
    case firstHalfStoppageTime
    case halftimeBreak
    case readyForSecondHalf
    case secondHalfRunning
    case secondHalfStoppageTime
    case finished
}
