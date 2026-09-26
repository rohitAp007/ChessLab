//import XCTest
//@testable import Chess
//
//final class ChessTests: XCTestCase {
//
//    func testInitialBoardContains32Pieces() {
//        var board = ChessBoard()
//        board.setupInitialPosition()
//
//        let pieces = board.squares.compactMap { $0 }
//        XCTAssertEqual(pieces.count, 32)
//    }
//
//    func testWhitePawnHasTwoOpeningMoves() {
//        var board = ChessBoard()
//        board.setupInitialPosition()
//
//        let validator = MoveValidator()
//        let moves = validator.legalMoves(
//            from: Position(row: 6, column: 4),
//            board: board,
//            currentTurn: .white,
//            castlingRights: CastlingRights(),
//            enPassantTarget: nil
//        )
//
//        XCTAssertEqual(moves.count, 2)
//    }
//
//    func testKnightCanJumpOverPieces() {
//        var board = ChessBoard()
//        board.setupInitialPosition()
//
//        let validator = MoveValidator()
//        let moves = validator.legalMoves(
//            from: Position(row: 7, column: 1),
//            board: board,
//            currentTurn: .white,
//            castlingRights: CastlingRights(),
//            enPassantTarget: nil
//        )
//
//        let destinations = Set(moves.map(\.to))
//        XCTAssertTrue(destinations.contains(Position(row: 5, column: 0)))
//        XCTAssertTrue(destinations.contains(Position(row: 5, column: 2)))
//    }
//}
