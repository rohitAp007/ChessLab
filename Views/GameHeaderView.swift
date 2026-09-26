import SwiftUI

struct GameHeaderView: View {
    let status: String
    let moveCount: Int

    var body: some View {
        VStack(spacing: 6) {
            Text("♟ ChessLab")
                .font(.largeTitle.bold())

            Text(status)
                .font(.headline)

            Text("\(moveCount) moves")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
