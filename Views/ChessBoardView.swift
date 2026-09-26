import SwiftUI

struct ChessBoardView: View {
    @ObservedObject var game: ChessGame

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { column in
                            let position = Position(row: row, column: column)

                            ChessSquareView(
                                piece: game.board[position],
                                position: position,
                                isSelected: game.selectedPosition == position,
                                isLegalMove: game.legalMoves.contains { $0.to == position },
                                isCapture: game.legalMoves.contains {
                                    $0.to == position && game.board[position] != nil
                                }
                            )
                            .frame(
                                width: size / 8,
                                height: size / 8
                            )
                            .onTapGesture {
                                game.select(position)
                            }
                        }
                    }
                }
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 8)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
