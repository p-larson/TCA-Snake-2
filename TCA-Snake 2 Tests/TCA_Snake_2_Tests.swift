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

final class TCA_Snake_2_Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testKeyDown() async {
        let store = TestStore(
            initialState: Snake.State(
            	width: 10,
                height: 10
            ), 
            reducer: Snake()
        )
        
        ([.space, KeyEquivalent.rightArrow, .leftArrow, .upArrow, .downArrow] as [KeyEquivalent]).map(\.character) 
        
//        await store.send(.key())
    }
    
//    let spawnFoodTask = AsyncThrowingStream<, Error>.streamWithContinuation()
    
    func testCoordinateGenerator() {
        let store = TestStore(
            initialState: Snake.State.init(
                width: Snake.minWidth, 
                height: Snake.minHeight
            ), 
            reducer: Snake()
        ) {
            $0.coordinateGenerator = .liveValue
        }
        
        measure(options: .default) { 
            store.send(.spawnFood)
        }
    }
    
    func testFullMap() async {
        let store = TestStore(
            initialState: Snake.State.init(
                width: Snake.minWidth, 
                height: Snake.minHeight
            ), 
            reducer: Snake()
        ) {
            $0.coordinateGenerator = .liveValue
        }
        
        
        
        await store.send(.gameTick)
        
    }

}
