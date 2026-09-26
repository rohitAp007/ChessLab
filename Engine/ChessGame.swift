import Foundation
import Combine

@MainActor
final class ChessGame: ObservableObject {

    @Published private(set) var board = ChessBoard()
    @Published private(set) var currentTurn: PieceColor = .white
    @Published private(set) var selectedPosition: Position?
    @Published private(set) var legalMoves: [ChessMove] = []
    @Published private(set) var moveHistory: [ChessMove] = []
    @Published private(set) var status = "White to move"
    @Published private(set) var gameOver = false

    private let validator = MoveValidator()
    private var castlingRights = CastlingRights()
    private var enPassantTarget: Position?

    private struct Snapshot {
        let board: ChessBoard
        let turn: PieceColor
        let castlingRights: CastlingRights
        let enPassantTarget: Position?
        let status: String
        let gameOver: Bool
    }

    private var history: [Snapshot] = []

    init() {
        newGame()
    }

    func newGame() {
        board.setupInitialPosition()
        currentTurn = .white
        selectedPosition = nil
        legalMoves = []
        moveHistory = []
        castlingRights = CastlingRights()
        enPassantTarget = nil
        status = "White to move"
        gameOver = false
        history.removeAll()
    }

    func select(_ position: Position) {
        guard !gameOver else { return }

        if let selectedPosition {
            if let move = legalMoves.first(where: { $0.to == position }) {
                makeMove(move)
                return
            }

            if board[position]?.color == currentTurn {
                selectOwnPiece(position)
            } else {
                clearSelection()
            }
            return
        }

        if board[position]?.color == currentTurn {
            selectOwnPiece(position)
        }
    }

    func undo() {
        guard let snapshot = history.popLast() else { return }

        board = snapshot.board
        currentTurn = snapshot.turn
        castlingRights = snapshot.castlingRights
        enPassantTarget = snapshot.enPassantTarget
        status = snapshot.status
        gameOver = snapshot.gameOver

        if !moveHistory.isEmpty {
            moveHistory.removeLast()
        }

        clearSelection()
    }

    func canUndo() -> Bool {
        !history.isEmpty
    }

    private func selectOwnPiece(_ position: Position) {
        selectedPosition = position
        legalMoves = validator.legalMoves(
            from: position,
            board: board,
            currentTurn: currentTurn,
            castlingRights: castlingRights,
            enPassantTarget: enPassantTarget
        )
    }

    private func clearSelection() {
        selectedPosition = nil
        legalMoves = []
    }

    private func makeMove(_ move: ChessMove) {
        history.append(
            Snapshot(
                board: board,
                turn: currentTurn,
                castlingRights: castlingRights,
                enPassantTarget: enPassantTarget,
                status: status,
                gameOver: gameOver
            )
        )

        guard let movingPiece = board[move.from] else {
            return
        }

        updateCastlingRights(
            move: move,
            movingPiece: movingPiece
        )

        var nextBoard = board
        apply(move: move, to: &nextBoard)

        board = nextBoard
        moveHistory.append(move)

        updateEnPassantTarget(
            move: move,
            movingPiece: movingPiece
        )

        currentTurn = currentTurn.opposite
        clearSelection()
        updateGameStatus()
    }

    private func apply(
        move: ChessMove,
        to board: inout ChessBoard
    ) {
        guard let piece = board[move.from] else { return }

        board[move.from] = nil

        if move.isEnPassant {
            let captureRow = piece.color == .white
                ? move.to.row + 1
                : move.to.row - 1

            board[
                Position(
                    row: captureRow,
                    column: move.to.column
                )
            ] = nil
        }

        if move.isCastle {
            let row = move.from.row

            if move.to.column == 6 {
                let rookFrom = Position(row: row, column: 7)
                let rookTo = Position(row: row, column: 5)
                board[rookTo] = board[rookFrom]
                board[rookFrom] = nil
            } else {
                let rookFrom = Position(row: row, column: 0)
                let rookTo = Position(row: row, column: 3)
                board[rookTo] = board[rookFrom]
                board[rookFrom] = nil
            }
        }

        board[move.to] = ChessPiece(
            type: move.promotion ?? piece.type,
            color: piece.color
        )
    }

    private func updateCastlingRights(
        move: ChessMove,
        movingPiece: ChessPiece
    ) {
        if movingPiece.type == .king {
            if movingPiece.color == .white {
                castlingRights.whiteKingSide = false
                castlingRights.whiteQueenSide = false
            } else {
                castlingRights.blackKingSide = false
                castlingRights.blackQueenSide = false
            }
        }

        if movingPiece.type == .rook {
            disableRookCastlingRights(
                color: movingPiece.color,
                position: move.from
            )
        }

        if let capturedPiece = board[move.to],
           capturedPiece.type == .rook {
            disableRookCastlingRights(
                color: capturedPiece.color,
                position: move.to
            )
        }
    }

    private func disableRookCastlingRights(
        color: PieceColor,
        position: Position
    ) {
        switch (color, position.column) {
        case (.white, 0):
            castlingRights.whiteQueenSide = false
        case (.white, 7):
            castlingRights.whiteKingSide = false
        case (.black, 0):
            castlingRights.blackQueenSide = false
        case (.black, 7):
            castlingRights.blackKingSide = false
        default:
            break
        }
    }

    private func updateEnPassantTarget(
        move: ChessMove,
        movingPiece: ChessPiece
    ) {
        enPassantTarget = nil

        guard movingPiece.type == .pawn else { return }

        if abs(move.to.row - move.from.row) == 2 {
            enPassantTarget = Position(
                row: (move.to.row + move.from.row) / 2,
                column: move.from.column
            )
        }
    }

    private func updateGameStatus() {
        let legalMoves = validator.allLegalMoves(
            color: currentTurn,
            board: board,
            castlingRights: castlingRights,
            enPassantTarget: enPassantTarget
        )

        if legalMoves.isEmpty {
            if validator.isKingInCheck(
                color: currentTurn,
                board: board
            ) {
                gameOver = true
                status = "\(currentTurn.opposite.displayName) wins by checkmate"
            } else {
                gameOver = true
                status = "Draw by stalemate"
            }
            return
        }

        if validator.isKingInCheck(
            color: currentTurn,
            board: board
        ) {
            status = "\(currentTurn.displayName) is in check"
        } else {
            status = "\(currentTurn.displayName) to move"
        }
    }
}
