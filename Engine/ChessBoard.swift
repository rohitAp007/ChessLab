import Foundation

struct ChessBoard {
    var squares: [ChessPiece?] = Array(repeating: nil, count: 64)

    subscript(_ position: Position) -> ChessPiece? {
        get {
            guard position.isValid else { return nil }
            return squares[position.row * 8 + position.column]
        }
        set {
            guard position.isValid else { return }
            squares[position.row * 8 + position.column] = newValue
        }
    }

    mutating func setupInitialPosition() {
        squares = Array(repeating: nil, count: 64)

        let backRank: [PieceType] = [
            .rook, .knight, .bishop, .queen,
            .king, .bishop, .knight, .rook
        ]

        for column in 0..<8 {
            self[Position(row: 0, column: column)] =
                ChessPiece(type: backRank[column], color: .black)

            self[Position(row: 1, column: column)] =
                ChessPiece(type: .pawn, color: .black)

            self[Position(row: 6, column: column)] =
                ChessPiece(type: .pawn, color: .white)

            self[Position(row: 7, column: column)] =
                ChessPiece(type: backRank[column], color: .white)
        }
    }

    func piecePositions(for color: PieceColor) -> [Position] {
        var positions: [Position] = []

        for row in 0..<8 {
            for column in 0..<8 {
                let position = Position(row: row, column: column)
                if self[position]?.color == color {
                    positions.append(position)
                }
            }
        }

        return positions
    }

    func allPositions() -> [Position] {
        (0..<8).flatMap { row in
            (0..<8).map { column in
                Position(row: row, column: column)
            }
        }
    }
}
