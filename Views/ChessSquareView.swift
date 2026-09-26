import SwiftUI

struct ChessSquareView: View {
    let piece: ChessPiece?
    let position: Position
    let isSelected: Bool
    let isLegalMove: Bool
    let isCapture: Bool

    private var isLightSquare: Bool {
        (position.row + position.column).isMultiple(of: 2)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isLightSquare ? Color(red: 0.92, green: 0.82, blue: 0.68)
                                     : Color(red: 0.55, green: 0.32, blue: 0.18))

            if isSelected {
                Rectangle()
                    .stroke(Color.yellow, lineWidth: 4)
            }

            if isLegalMove {
                Circle()
                    .fill(Color.green.opacity(0.65))
                    .frame(width: isCapture ? 42 : 18, height: isCapture ? 42 : 18)
            }

            if let piece {
                Text(piece.symbol)
                    .font(.system(size: 42))
                    .shadow(color: .black.opacity(0.25), radius: 2)
                    .scaleEffect(isSelected ? 1.08 : 1.0)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
    }
}
