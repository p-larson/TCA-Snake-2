//
//  HighScoreClient.swift
//  TCA-Snake 2
//
//  Created by Peter Larson on 4/13/23.
//

import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

struct HighScoreClient {
    var getHighScore: @Sendable () async -> Int
    var setHighScore: @Sendable (Int) async -> Void
}

extension DependencyValues {
    var highScoreClient: HighScoreClient {
        get { self[HighScoreClient.self] }
        set { self[HighScoreClient.self] = newValue }
    }
}

private final actor Storage {
    let storage = UserDefaults(suiteName: "com.larson.snake-2.highscore")
    
    func getHighScore() -> Int {
        storage?.integer(forKey: "value") ?? 1
    }
    
    func setHighScore(_ newValue: Int) {
        storage?.set(newValue, forKey: "value")
    }
}

extension HighScoreClient: DependencyKey {
    static var liveValue: HighScoreClient {
        let storage = Storage()
        
        return Self(
            getHighScore: {
                return await storage.getHighScore()
            }, setHighScore: { newValue in
                await storage.setHighScore(newValue)
            }
        )
    }
    
    static let testValue = Self(
        getHighScore: { return 1_000 }, 
        setHighScore: { _ in return }
    )
}
