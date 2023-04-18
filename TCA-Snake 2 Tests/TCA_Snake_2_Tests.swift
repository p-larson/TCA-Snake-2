//
//  TCA_Snake_2_Tests.swift
//  TCA-Snake 2 Tests
//
//  Created by Peter Larson on 4/9/23.
//

import XCTest
import ComposableArchitecture
import SwiftUI
@testable import TCA_Snake_2

@MainActor // ensures this is ran on the main thread!
final class TCA_Snake_2_Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSpawn() async {
        let store = TestStore(
            initialState: Snake.State(
            	width: 10,
                height: 10
            ), 
            reducer: Snake()
        )
                
        await store.send(.reset) {
            $0.status = .ready
        }
        
        await store.receive(.spawnFood)
        await store.receive(.checkScore)
        
        await store.receive(.updateHighScore(1_000)) {
            $0.highscore = 1_000
        }
        
        await store.receive(.findNextFoodCoordinate(.success(Coordinate(x: 1, y: 1)))) {
            $0.food = Coordinate(1, 1)
        }
        
    }
    
    func testWin() async {
        let store = TestStore(
            initialState: Snake.State(
                width: 10,
                height: 10,
                player: (0 ..< 100).map {
                    Coordinate($0 % 10, $0 / 10)
                }
            ), 
            reducer: Snake()
        )
        
        await store.send(.gameTick)
        await store.receive(.win)
    }
    
    func testFailSpawn() async {
        let store = TestStore(
            initialState: Snake.State(
                width: 1,
                height: 1,
                player: [.zero]
            ), 
            reducer: Snake()
        ) {
            $0.coordinateGenerator = .liveValue
        }
        
        await store.send(.spawnFood)
        await store.receive(
            .findNextFoodCoordinate(
                .failure(
                    CoordinateGenerator
                        .GenerationError
                        .noAvailableCoordinate
                )
            )
        )
        await store.receive(.die)
    }
    
    func testCanvas() async {
        let store = TestStore(
            initialState: Snake.State(
                width: 1,
                height: 1,
                player: [.zero]
            ), 
            reducer: Snake()
        )
        
        store.exhaustivity = .off(showSkippedAssertions: false)
        
        await store.send(
            .canvas(
                CGSize(
                    width: Snake.cellSize * Snake.minHeight, 
                    height: Snake.cellSize * Snake.minHeight
                )
            )
        ) {
            $0.width = Snake.minWidth
            $0.height = Snake.minHeight
        }
    }
    
//	TODO: Refactor 
// 	https://forums.swift.org/t/how-to-test-receiving-merged-effects/61275
//    func testHighScore() async {
//        let store = TestStore(
//            initialState: {
//                var state = Snake.State(width: 5, height: 5)
//                
//                state.player = [.zero]
//                state.food = Coordinate(1, 0)
//                state.direction = .right
//                
//                return state
//            }(), 
//            reducer: Snake()
//        ) {
//            $0.highScoreClient = .liveValue
//        }
//
//        
//        await store.send(.gameTick) {
//            $0.player = [.zero + Vector.right, .zero]   
//        }
//        await store.receive(.spawnFood)
//        await store.receive(.checkScore)
//        
//        await store.receive(.updateHighScore(2)) {
//            $0.highscore = 2
//        }
//        
//        await store.receive(.findNextFoodCoordinate(.success(Coordinate(1, 1)))) {
//            $0.food = Coordinate(1, 1)
//        }
//    }
}
