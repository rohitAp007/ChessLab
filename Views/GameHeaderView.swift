import SwiftUI

struct GameHeaderView: View {
    let status: String
    let moveCount: Int

    @ObservedObject var clock: ChessClock

    var body: some View {
        VStack(spacing: 8) {

            Text("♟ ChessLab")
                .font(.largeTitle.bold())

            HStack(spacing: 12) {

                PlayerClockView(
                    title: "White",
                    time: clock.formattedTime(for: .white),
                    isActive: clock.activeColor == .white,
                    isExpired: clock.whiteSeconds <= 0
                )

                PlayerClockView(
                    title: "Black",
                    time: clock.formattedTime(for: .black),
                    isActive: clock.activeColor == .black,
                    isExpired: clock.blackSeconds <= 0
                )
            }

            Text(status)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("\(moveCount) moves")
                .font(.caption)
                .foregroundStyle(Color.secondary)
        }
    }
}

private struct PlayerClockView: View {

    let title: String
    let time: String
    let isActive: Bool
    let isExpired: Bool

    var body: some View {
        VStack(spacing: 2) {

            Text(title)
                .font(.caption)
                .foregroundStyle(Color.secondary)

            Text(time)
                .font(
                    .system(
                        .title2,
                        design: .monospaced
                    )
                    .bold()
                )
                .foregroundStyle(
                    isExpired
                        ? Color.red
                        : Color.primary
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)

        // Use Material explicitly instead of `.thinMaterial`
        // to avoid SwiftUI type inference issues.
        .background(
            isActive
                ? AnyShapeStyle(Material.thinMaterial)
                : AnyShapeStyle(Color.clear),
            in: RoundedRectangle(cornerRadius: 12)
        )

        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isActive
                        ? Color.primary.opacity(0.25)
                        : Color.clear,
                    lineWidth: 1
                )
        }
    }
}

//import SwiftUI
//
//struct GameHeaderView: View {
//    let status: String
//    let moveCount: Int
//
//    var body: some View {
//        VStack(spacing: 6) {
//            Text("♟ ChessLab")
//                .font(.largeTitle.bold())
//
//            Text(status)
//                .font(.headline)
//
//            Text("\(moveCount) moves")
//                .font(.caption)
//                .foregroundStyle(.secondary)
//        }
//    }
//}
