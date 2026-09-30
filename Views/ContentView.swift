import SwiftUI

struct ContentView: View {

    @StateObject private var game = ChessGame()

    @State private var selectedTimeControl:
        GameTimeControl = .default

    var body: some View {

        NavigationStack {

            VStack(spacing: 16) {

                GameHeaderView(
                    status: game.status,
                    moveCount: game.moveHistory.count,
                    clock: game.clock
                )

                ChessBoardView(game: game)

                HStack(spacing: 12) {

                    Button {
                        game.undo()
                    } label: {
                        Label(
                            "Undo",
                            systemImage: "arrow.uturn.backward"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!game.canUndo())

                    Button {
                        game.newGame(
                            timeControl: selectedTimeControl
                        )
                    } label: {
                        Label(
                            "New Game",
                            systemImage: "arrow.clockwise"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Menu {

                    ForEach(
                        GameTimeControl.allCases
                    ) { timeControl in

                        Button {

                            selectedTimeControl =
                                timeControl

                            game.newGame(
                                timeControl: timeControl
                            )

                        } label: {

                            if selectedTimeControl ==
                                timeControl {

                                Label(
                                    timeControl.rawValue,
                                    systemImage: "checkmark"
                                )

                            } else {

                                Text(
                                    timeControl.rawValue
                                )
                            }
                        }
                    }

                } label: {

                    Label(
                        "Time: \(selectedTimeControl.rawValue)",
                        systemImage: "clock"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                if !game.moveHistory.isEmpty {

                    ScrollView(
                        .horizontal,
                        showsIndicators: false
                    ) {

                        HStack(spacing: 8) {

                            ForEach(
                                Array(
                                    game.moveHistory.enumerated()
                                ),
                                id: \.offset
                            ) { index, move in

                                Text(
                                    "\(index + 1). \(move.notation)"
                                )
                                .font(
                                    .caption.monospaced()
                                )
                                .padding(
                                    .horizontal,
                                    8
                                )
                                .padding(
                                    .vertical,
                                    5
                                )
                                .background(
                                    Capsule()
                                        .fill(.thinMaterial)
                                )
                            }
                        }
                    }
                }

                Text(
                    "Tap a piece, then tap a highlighted square."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)

            .onChange(
                of: game.clock.whiteSeconds
            ) { _, _ in
                game.checkClockTimeout()
            }

            .onChange(
                of: game.clock.blackSeconds
            ) { _, _ in
                game.checkClockTimeout()
            }
        }
    }
}

#Preview {
    ContentView()
}
//import SwiftUI
//
//struct ContentView: View {
//    @StateObject private var game = ChessGame()
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 16) {
//                GameHeaderView(
//                    status: game.status,
//                    moveCount: game.moveHistory.count
//                )
//
//                ChessBoardView(game: game)
//
//                HStack(spacing: 12) {
//                    Button {
//                        game.undo()
//                    } label: {
//                        Label("Undo", systemImage: "arrow.uturn.backward")
//                            .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(.bordered)
//                    .disabled(!game.canUndo())
//
//                    Button {
//                        game.newGame()
//                    } label: {
//                        Label("New Game", systemImage: "arrow.clockwise")
//                            .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(.borderedProminent)
//                }
//
//                if !game.moveHistory.isEmpty {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 8) {
//                            ForEach(
//                                Array(game.moveHistory.enumerated()),
//                                id: \.offset
//                            ) { index, move in
//                                Text("\(index + 1). \(move.notation)")
//                                    .font(.caption.monospaced())
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 5)
//                                    .background(
//                                        Capsule()
//                                            .fill(.thinMaterial)
//                                    )
//                            }
//                        }
//                    }
//                }
//
//                Text("Tap a piece, then tap a highlighted square.")
//                    .font(.footnote)
//                    .foregroundStyle(.secondary)
//            }
//            .padding()
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
//
////next feature
//
//
