//
//  Snake.swift
//  TCA-Snake 2
//
//  Created by Peter Larson on 4/3/23.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import Clocks

struct Snake: ReducerProtocol {
    static let minWidth: Int = 5
    static let minHeight: Int = 5
    static let cellSize: Int = 20
    
    struct State: Equatable {
        var player: [Coordinate]
        var food: Coordinate
        var direction: Vector = .zero
        var width, height: Int
        var status: Status = .gameover
        
        init(
            width: Int = 40,
            height: Int = 30,
            start: Coordinate? = nil,
            food: Coordinate? = nil
        ) {
            self.width = width
            self.height = height
            self.player = [.zero]
            self.food = .zero
        }
        
        enum Status: Equatable {
            case ready, paused, playing, gameover
        }
    }
    
    enum Action: Equatable {
        case gameTick
        case canvas(CGSize)
        case reset
        case start
        case die
        case win
        case spawnFood
        case findCoordinate(TaskResult<Coordinate>)
        case key(Character)
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.coordinateGenerator) var coordinateGenerator
    
    struct TimerID: Hashable {
        // Gotta be a better way to do this TCA!
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .gameTick:
            guard let current = state.player.first else {
                return EffectTask(value: .die)
            }
            
            let future = current + state.direction
            
            let inBounds = future.isInBounds(state.width, state.height)
            let hasCollided = Set(state.player).count != state.player.count
            
            if !inBounds || hasCollided {
                return EffectTask(value: .die)
            }
            
            state.player.insert(future, at: state.player.startIndex)
            
            if state.player.count == state.height * state.width {
                return EffectTask(value: .win)
            }
            
            if future != state.food {
                state.player.removeLast()
            } else {
                return .send(.spawnFood) 
            }
            
            return .none
        case .canvas(let size):
            state.width = max(Int(size.width) / Snake.cellSize, Snake.minWidth)
            state.height = max(Int(size.height) / Snake.cellSize, Snake.minHeight)
            
            return .send(.reset)
        case .start:
            guard state.status != .gameover else {
                return .none
            }
            
            return .concatenate(.cancel(id: TimerID.self), .run { send in 
                for await _ in self.clock.timer(interval: .milliseconds(100)) {
                    await send(.gameTick)
                }
            }
                .cancellable(id: TimerID.self, cancelInFlight: true))
        case .die:
            state.status = .gameover
            return .cancel(id: TimerID.self)
        case .win:
            state.status = .gameover
            return .none
        case .spawnFood:
            return .task { [width = state.width, height = state.height, player = state.player] in
                await .findCoordinate(TaskResult<Coordinate> {
                    try await coordinateGenerator.findOpenCoordinate(width, height, player)
                })
            }
        case .findCoordinate(.success(let coordinate)):
            state.food = coordinate
            
            return .none
        case .findCoordinate(.failure):
            return .send(.die)
        case .key(let character):
            var newDirection = Vector.zero
            
            switch character {
            case KeyEquivalent.space.character:
                return .send(.reset)
            case KeyEquivalent.leftArrow.character:
                newDirection = .left
            case KeyEquivalent.rightArrow.character:
                newDirection = .right
            case KeyEquivalent.upArrow.character:
                newDirection = .up
            case KeyEquivalent.downArrow.character:
                newDirection = .down
            default: break           
            }
            
            if state.status == .ready 
                || (newDirection != (state.direction * -1) && state.status == .playing)
            {
                state.direction = newDirection
                
                return .merge(.send(.gameTick), .send(.start))
            }
            
            return .none
        case .reset:
            state.player = [.start]
            state.status = .ready
            state.direction = .zero
            
            return .send(.spawnFood)
        }
    }
}
