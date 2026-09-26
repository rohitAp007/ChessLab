import SwiftUI

struct ContentView: View {
    @StateObject private var game = ChessGame()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                GameHeaderView(
                    status: game.status,
                    moveCount: game.moveHistory.count
                )

                ChessBoardView(game: game)

                HStack(spacing: 12) {
                    Button {
                        game.undo()
                    } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!game.canUndo())

                    Button {
                        game.newGame()
                    } label: {
                        Label("New Game", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                if !game.moveHistory.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(
                                Array(game.moveHistory.enumerated()),
                                id: \.offset
                            ) { index, move in
                                Text("\(index + 1). \(move.notation)")
                                    .font(.caption.monospaced())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(.thinMaterial)
                                    )
                            }
                        }
                    }
                }

                Text("Tap a piece, then tap a highlighted square.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}

//next feature


