//
//  CoordinateGenerator.swift
//  TCA-Snake 2
//
//  Created by Peter Larson on 4/11/23.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay

struct CoordinateGenerator {
    var findOpenCoordinate: @Sendable (Int, Int, [Coordinate]) async throws -> Coordinate
    
    static func random(width: Int, height: Int) -> Coordinate {
    	Coordinate(
           x: .random(in: 0 ..< width), 
           y: .random(in: 0 ..< height)
       )
    }
    
    enum GenerationError: Error {
        case noAvailableCoordinate
    }
}

extension DependencyValues {
    var coordinateGenerator: CoordinateGenerator {
        get { self[CoordinateGenerator.self] }
        set { self[CoordinateGenerator.self] = newValue }
    }
}

extension CoordinateGenerator: DependencyKey {
    static let liveValue = Self(
        findOpenCoordinate: { width, height, player in 
            var attempt = 0
            
            while attempt < 10_000 {
                
                let random = random(width: width, height: height)
                
                if !player.contains(random) {
                    return random
                }
                
                attempt += 1
            }
            
            throw CoordinateGenerator.GenerationError.noAvailableCoordinate
        }
    )
    
    static let testValue = Self(
        findOpenCoordinate: unimplemented("\(Self.self).findOpenCoordinate")
    )
}
