# ♟️ ChessLab

> An open-source native iOS chess application built with Swift and SwiftUI.

[Features] · [Architecture] · [Contributing] · [Roadmap]

## 📱 About

ChessLab is an open-source chess application for iOS,
built to explore modern native iOS development using
Swift and SwiftUI.

The project is also designed to be a learning-friendly
codebase where developers can contribute new features,
improvements, tests, and documentation.

## ✨ Features

- [x] Chess board
- [x] Piece movement
- [x] Captures
- [x] Turn management
- [x] Check detection
- [x] Checkmate detection
- [x] Stalemate detection
- [x] Castling
- [x] En passant
- [x] Pawn promotion
- [x] Undo
- [x] Move history
- [ ] Chess clock
- [ ] Game persistence
- [ ] FEN support
- [ ] PGN support
- [ ] AI opponent
- [ ] Stockfish integration
- [ ] Online multiplayer

## 🛠 Tech Stack

- Swift
- SwiftUI
- Swift Concurrency
- SwiftData
- XCTest

## 🏗 Architecture

```text
SwiftUI
   ↓
Views
   ↓
Game State
   ↓
Chess Engine
   ↓
Move Validator
   ↓
Chess Models
