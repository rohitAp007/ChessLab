import Foundation

struct CastlingRights: Codable, Equatable {
    var whiteKingSide = true
    var whiteQueenSide = true
    var blackKingSide = true
    var blackQueenSide = true
}

struct MoveValidator {

    func pseudoLegalMoves(
        from position: Position,
        board: ChessBoard,
        currentTurn: PieceColor,
        castlingRights: CastlingRights,
        enPassantTarget: Position?
    ) -> [ChessMove] {
        guard let piece = board[position], piece.color == currentTurn else {
            return []
        }

        switch piece.type {
        case .pawn:
            return pawnMoves(
                from: position,
                board: board,
                color: piece.color,
                enPassantTarget: enPassantTarget
            )
        case .knight:
            return jumpMoves(
                from: position,
                board: board,
                color: piece.color,
                offsets: [
                    (-2, -1), (-2, 1), (-1, -2), (-1, 2),
                    (1, -2), (1, 2), (2, -1), (2, 1)
                ]
            )
        case .bishop:
            return slidingMoves(
                from: position,
                board: board,
                color: piece.color,
                directions: [
                    (-1, -1), (-1, 1), (1, -1), (1, 1)
                ]
            )
        case .rook:
            return slidingMoves(
                from: position,
                board: board,
                color: piece.color,
                directions: [
                    (-1, 0), (1, 0), (0, -1), (0, 1)
                ]
            )
        case .queen:
            return slidingMoves(
                from: position,
                board: board,
                color: piece.color,
                directions: [
                    (-1, -1), (-1, 1), (1, -1), (1, 1),
                    (-1, 0), (1, 0), (0, -1), (0, 1)
                ]
            )
        case .king:
            return kingMoves(
                from: position,
                board: board,
                color: piece.color,
                castlingRights: castlingRights
            )
        }
    }

    func legalMoves(
        from position: Position,
        board: ChessBoard,
        currentTurn: PieceColor,
        castlingRights: CastlingRights,
        enPassantTarget: Position?
    ) -> [ChessMove] {
        let candidates = pseudoLegalMoves(
            from: position,
            board: board,
            currentTurn: currentTurn,
            castlingRights: castlingRights,
            enPassantTarget: enPassantTarget
        )

        return candidates.filter { move in
            // In chess, the king is never captured. Checkmate ends the game.
            if board[move.to]?.type == .king {
                return false
            }

            var testBoard = board
            apply(move: move, to: &testBoard)
            return !isKingInCheck(
                color: currentTurn,
                board: testBoard
            )
        }
    }

    func allLegalMoves(
        color: PieceColor,
        board: ChessBoard,
        castlingRights: CastlingRights,
        enPassantTarget: Position?
    ) -> [ChessMove] {
        board.piecePositions(for: color).flatMap { position in
            legalMoves(
                from: position,
                board: board,
                currentTurn: color,
                castlingRights: castlingRights,
                enPassantTarget: enPassantTarget
            )
        }
    }

    func isKingInCheck(
        color: PieceColor,
        board: ChessBoard
    ) -> Bool {
        guard let kingPosition = board.piecePositions(for: color).first(where: {
            board[$0]?.type == .king
        }) else {
            return true
        }

        return isSquareAttacked(
            kingPosition,
            by: color.opposite,
            board: board
        )
    }

    func isSquareAttacked(
        _ target: Position,
        by attacker: PieceColor,
        board: ChessBoard
    ) -> Bool {
        for position in board.piecePositions(for: attacker) {
            guard let piece = board[position] else { continue }

            let rowDelta = target.row - position.row
            let colDelta = target.column - position.column

            switch piece.type {
            case .pawn:
                let direction = attacker == .white ? -1 : 1
                if rowDelta == direction && abs(colDelta) == 1 {
                    return true
                }

            case .knight:
                if [
                    (-2, -1), (-2, 1), (-1, -2), (-1, 2),
                    (1, -2), (1, 2), (2, -1), (2, 1)
                ].contains(where: { $0.0 == rowDelta && $0.1 == colDelta }) {
                    return true
                }

            case .king:
                if max(abs(rowDelta), abs(colDelta)) == 1 {
                    return true
                }

            case .bishop:
                if abs(rowDelta) == abs(colDelta),
                   rowDelta != 0,
                   pathIsClear(from: position, to: target, board: board) {
                    return true
                }

            case .rook:
                if (rowDelta == 0 || colDelta == 0),
                   (rowDelta != 0 || colDelta != 0),
                   pathIsClear(from: position, to: target, board: board) {
                    return true
                }

            case .queen:
                let diagonal = abs(rowDelta) == abs(colDelta) && rowDelta != 0
                let straight = (rowDelta == 0 || colDelta == 0) &&
                    (rowDelta != 0 || colDelta != 0)

                if (diagonal || straight),
                   pathIsClear(from: position, to: target, board: board) {
                    return true
                }
            }
        }

        return false
    }

    private func pawnMoves(
        from position: Position,
        board: ChessBoard,
        color: PieceColor,
        enPassantTarget: Position?
    ) -> [ChessMove] {
        var moves: [ChessMove] = []
        let direction = color == .white ? -1 : 1
        let startRow = color == .white ? 6 : 1
        let promotionRow = color == .white ? 0 : 7

        let oneStep = Position(
            row: position.row + direction,
            column: position.column
        )

        if oneStep.isValid && board[oneStep] == nil {
            if oneStep.row == promotionRow {
                moves.append(contentsOf: promotionMoves(from: position, to: oneStep))
            } else {
                moves.append(
                    ChessMove(from: position, to: oneStep)
                )
            }

            let twoStep = Position(
                row: position.row + 2 * direction,
                column: position.column
            )

            if position.row == startRow &&
                board[twoStep] == nil {
                moves.append(
                    ChessMove(from: position, to: twoStep)
                )
            }
        }

        for columnOffset in [-1, 1] {
            let capture = Position(
                row: position.row + direction,
                column: position.column + columnOffset
            )

            guard capture.isValid else { continue }

            if let targetPiece = board[capture],
               targetPiece.color != color {
                if capture.row == promotionRow {
                    moves.append(contentsOf: promotionMoves(from: position, to: capture))
                } else {
                    moves.append(
                        ChessMove(from: position, to: capture)
                    )
                }
            } else if capture == enPassantTarget {
                moves.append(
                    ChessMove(
                        from: position,
                        to: capture,
                        isEnPassant: true
                    )
                )
            }
        }

        return moves
    }

    private func promotionMoves(
        from: Position,
        to: Position
    ) -> [ChessMove] {
        [.queen, .rook, .bishop, .knight].map {
            ChessMove(
                from: from,
                to: to,
                promotion: $0
            )
        }
    }

    private func jumpMoves(
        from position: Position,
        board: ChessBoard,
        color: PieceColor,
        offsets: [(Int, Int)]
    ) -> [ChessMove] {
        offsets.compactMap { rowOffset, columnOffset in
            let target = Position(
                row: position.row + rowOffset,
                column: position.column + columnOffset
            )

            guard target.isValid else { return nil }

            if let piece = board[target], piece.color == color {
                return nil
            }

            return ChessMove(from: position, to: target)
        }
    }

    private func slidingMoves(
        from position: Position,
        board: ChessBoard,
        color: PieceColor,
        directions: [(Int, Int)]
    ) -> [ChessMove] {
        var moves: [ChessMove] = []

        for (rowDirection, columnDirection) in directions {
            var row = position.row + rowDirection
            var column = position.column + columnDirection

            while Position(row: row, column: column).isValid {
                let target = Position(row: row, column: column)

                if let piece = board[target] {
                    if piece.color != color {
                        moves.append(ChessMove(from: position, to: target))
                    }
                    break
                }

                moves.append(ChessMove(from: position, to: target))

                row += rowDirection
                column += columnDirection
            }
        }

        return moves
    }

    private func kingMoves(
        from position: Position,
        board: ChessBoard,
        color: PieceColor,
        castlingRights: CastlingRights
    ) -> [ChessMove] {
        var moves = jumpMoves(
            from: position,
            board: board,
            color: color,
            offsets: [
                (-1, -1), (-1, 0), (-1, 1),
                (0, -1), (0, 1),
                (1, -1), (1, 0), (1, 1)
            ]
        )

        let row = color == .white ? 7 : 0

        guard position == Position(row: row, column: 4) else {
            return moves
        }

        guard !isKingInCheck(color: color, board: board) else {
            return moves
        }

        let kingSideAllowed = color == .white
            ? castlingRights.whiteKingSide
            : castlingRights.blackKingSide

        if kingSideAllowed {
            let squares = [
                Position(row: row, column: 5),
                Position(row: row, column: 6)
            ]

            if squares.allSatisfy({ board[$0] == nil }),
               !isSquareAttacked(squares[0], by: color.opposite, board: board),
               !isSquareAttacked(squares[1], by: color.opposite, board: board),
               board[Position(row: row, column: 7)]?.type == .rook,
               board[Position(row: row, column: 7)]?.color == color {
                moves.append(
                    ChessMove(
                        from: position,
                        to: squares[1],
                        isCastle: true
                    )
                )
            }
        }

        let queenSideAllowed = color == .white
            ? castlingRights.whiteQueenSide
            : castlingRights.blackQueenSide

        if queenSideAllowed {
            let squares = [
                Position(row: row, column: 1),
                Position(row: row, column: 2),
                Position(row: row, column: 3)
            ]

            if squares.allSatisfy({ board[$0] == nil }),
               !isSquareAttacked(squares[2], by: color.opposite, board: board),
               !isSquareAttacked(squares[3], by: color.opposite, board: board),
               board[Position(row: row, column: 0)]?.type == .rook,
               board[Position(row: row, column: 0)]?.color == color {
                moves.append(
                    ChessMove(
                        from: position,
                        to: squares[2],
                        isCastle: true
                    )
                )
            }
        }

        return moves
    }

    private func pathIsClear(
        from: Position,
        to: Position,
        board: ChessBoard
    ) -> Bool {
        let rowDirection = (to.row - from.row).signum()
        let columnDirection = (to.column - from.column).signum()

        var row = from.row + rowDirection
        var column = from.column + columnDirection

        while Position(row: row, column: column) != to {
            if board[Position(row: row, column: column)] != nil {
                return false
            }

            row += rowDirection
            column += columnDirection
        }

        return true
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
            } else if move.to.column == 2 {
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
}
