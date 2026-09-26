import Foundation

enum PieceColor: String, Codable, CaseIterable {
    case white
    case black

    var opposite: PieceColor {
        self == .white ? .black : .white
    }

    var displayName: String {
        self == .white ? "White" : "Black"
    }
}

enum PieceType: String, Codable, CaseIterable {
    case king
    case queen
    case rook
    case bishop
    case knight
    case pawn

    var symbol: String {
        switch self {
        case .king: return "♚"
        case .queen: return "♛"
        case .rook: return "♜"
        case .bishop: return "♝"
        case .knight: return "♞"
        case .pawn: return "♟"
        }
    }
}

struct ChessPiece: Codable, Hashable {
    let type: PieceType
    let color: PieceColor

    var symbol: String {
        let whiteSymbols: [PieceType: String] = [
            .king: "♔", .queen: "♕", .rook: "♖",
            .bishop: "♗", .knight: "♘", .pawn: "♙"
        ]

        if color == .white {
            return whiteSymbols[type] ?? type.symbol
        }

        return type.symbol
    }
}

struct Position: Hashable, Codable {
    let row: Int
    let column: Int

    var isValid: Bool {
        (0..<8).contains(row) && (0..<8).contains(column)
    }

    var algebraic: String {
        guard isValid else { return "?" }
        let files = Array("abcdefgh")
        return "\(files[column])\(8 - row)"
    }
}

struct ChessMove: Hashable, Codable {
    let from: Position
    let to: Position
    let promotion: PieceType?
    let isCastle: Bool
    let isEnPassant: Bool

    init(
        from: Position,
        to: Position,
        promotion: PieceType? = nil,
        isCastle: Bool = false,
        isEnPassant: Bool = false
    ) {
        self.from = from
        self.to = to
        self.promotion = promotion
        self.isCastle = isCastle
        self.isEnPassant = isEnPassant
    }

    var notation: String {
        "\(from.algebraic)-\(to.algebraic)"
    }
}
