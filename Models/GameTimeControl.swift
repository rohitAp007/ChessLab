//
//  GameTimeControl.swift
//  Chess
//
//  Created by Shalan on 28/09/26.
//
import Foundation

enum GameTimeControl: String, CaseIterable, Identifiable {
    case oneMinute = "1 + 0"
    case threeMinutes = "3 + 0"
    case fiveMinutes = "5 + 0"
    case tenMinutes = "10 + 0"
    case fifteenMinutes = "15 + 0"

    var id: String { rawValue }

    var seconds: TimeInterval {
        switch self {
        case .oneMinute: return 60
        case .threeMinutes: return 180
        case .fiveMinutes: return 300
        case .tenMinutes: return 600
        case .fifteenMinutes: return 900
        }
    }

    var displayName: String {
        switch self {
        case .oneMinute: return "1 minute"
        case .threeMinutes: return "3 minutes"
        case .fiveMinutes: return "5 minutes"
        case .tenMinutes: return "10 minutes"
        case .fifteenMinutes: return "15 minutes"
        }
    }

    static var `default`: GameTimeControl {
        .fiveMinutes
    }
}
