# ChessLab — SwiftUI Chess Starter

Target: iOS 17+ / Swift 5.9+ (works with current Xcode versions).

## Folder structure

Chess/
├── ChessApp.swift
├── Models/
│   └── ChessModels.swift
├── Engine/
│   ├── ChessBoard.swift
│   ├── MoveValidator.swift
│   └── ChessGame.swift
├── Views/
│   ├── ContentView.swift
│   ├── ChessBoardView.swift
│   ├── ChessSquareView.swift
│   └── GameHeaderView.swift
└── Tests/
    └── ChessTests.swift

## How to use

1. Create an iOS SwiftUI project named `Chess` in Xcode.
2. Delete the template `Item.swift` if it exists.
3. Create the `Models`, `Engine`, and `Views` groups.
4. Add the source files from this package to the Chess app target.
5. Add `Tests/ChessTests.swift` to the `ChessTests` target.
6. Build and run.

The implementation includes:
- 8x8 chess board
- All six piece movement types
- Captures
- Turn management
- Check/checkmate
- Stalemate
- Castling
- En passant
- Pawn promotion
- Undo
- Move history
- Unit tests

This is a local two-player foundation. AI/Stockfish, clocks, persistence, PGN/FEN, and online multiplayer can be added as separate features.
