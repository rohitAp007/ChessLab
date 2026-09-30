//
//  ChessClock.swift
//  Chess
//
//  Created by Shalan on 28/09/26.
//

import Foundation
import Combine

@MainActor
final class ChessClock: ObservableObject {

    struct State {
        let whiteSeconds: TimeInterval
        let blackSeconds: TimeInterval
        let activeColor: PieceColor?
        let isRunning: Bool
    }

    @Published private(set) var whiteSeconds: TimeInterval
    @Published private(set) var blackSeconds: TimeInterval
    @Published private(set) var activeColor: PieceColor?
    @Published private(set) var isRunning = false

    private(set) var timeControl: GameTimeControl

    private var timer: Timer?
    private var lastTick: Date?

    init(timeControl: GameTimeControl = .fiveMinutes) {
        self.timeControl = timeControl
        self.whiteSeconds = timeControl.seconds
        self.blackSeconds = timeControl.seconds
    }

    deinit {
        timer?.invalidate()
    }

    func reset(to timeControl: GameTimeControl) {
        stop()

        self.timeControl = timeControl
        whiteSeconds = timeControl.seconds
        blackSeconds = timeControl.seconds
        activeColor = nil
    }

    func start(for color: PieceColor) {
        guard !isRunning else { return }

        activeColor = color
        isRunning = true
        lastTick = Date()

        timer?.invalidate()

        timer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }

            Task { @MainActor in
                self.tick()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil

        isRunning = false
        lastTick = nil
    }

    func state() -> State {
        State(
            whiteSeconds: whiteSeconds,
            blackSeconds: blackSeconds,
            activeColor: activeColor,
            isRunning: isRunning
        )
    }

    func restore(_ state: State) {
        stop()

        whiteSeconds = state.whiteSeconds
        blackSeconds = state.blackSeconds
        activeColor = state.activeColor

        if state.isRunning,
           let activeColor = state.activeColor {
            start(for: activeColor)
        }
    }

    func formattedTime(for color: PieceColor) -> String {
        let seconds = color == .white
            ? whiteSeconds
            : blackSeconds

        let totalSeconds = max(
            0,
            Int(ceil(seconds))
        )

        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60

        return String(
            format: "%02d:%02d",
            minutes,
            remainingSeconds
        )
    }

    private func tick() {
        guard isRunning,
              let activeColor,
              let lastTick else {
            return
        }

        let elapsed = Date().timeIntervalSince(lastTick)

        self.lastTick = Date()

        switch activeColor {
        case .white:
            whiteSeconds = max(
                0,
                whiteSeconds - elapsed
            )

        case .black:
            blackSeconds = max(
                0,
                blackSeconds - elapsed
            )
        }

        if (activeColor == .white && whiteSeconds <= 0) ||
           (activeColor == .black && blackSeconds <= 0) {
            stop()
        }
    }
}
