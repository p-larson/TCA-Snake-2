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
    static let minWidth: Int = 20
    static let minHeight: Int = 15
    static let defaultWidth: Int = 40
    static let defaultHeight: Int = 30
    static let cellSize: Int = 20
    
    struct State: Equatable {
        var width: Int 
        var height: Int
        var player: [Coordinate]
        var food: Coordinate
        var direction: Vector = .zero
        var status: Status = .gameover
        var highscore: Int = 0
        
        init(
            width: Int = Snake.defaultWidth,
            height: Int = Snake.defaultHeight,
            player: [Coordinate] = [.start],
            food: Coordinate = .zero
        ) {
            self.width = width
            self.height = height
            self.player = player
            self.food = food
        }
        
        enum Status: Equatable {
            case ready, paused, playing, gameover
        }
    }
    
    enum Action: Equatable, BindableAction {
        case gameTick
        case canvas(CGSize)
        case reset
        case start
        case die
        case win
        case checkScore
        case updateHighScore(Int)
        case spawnFood
        case findNextFoodCoordinate(TaskResult<Coordinate>)
        case key(Character)
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.coordinateGenerator) var coordinateGenerator
    @Dependency(\.highScoreClient) var highScoreClient
    
    struct TimerID: Hashable {
        // Gotta be a better way to do this TCA!
    }
    
    struct SpawnFoodID: Hashable {
        // ...
    }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in 
            switch action {
            case .gameTick:
                // This should never happen
                guard let current = state.player.first else {
                    return EffectTask(value: .die)
                }
                
                if state.player.count == state.height * state.width {
                    return EffectTask(value: .win)
                }
            
                let future: Coordinate = current + state.direction
                
                let inBounds: Bool = future.isInBounds(state.width, state.height)
                let hasCollided: Bool = Set(state.player).count != state.player.count
                
                if !inBounds || hasCollided {
                    return EffectTask(value: .die)
                }
                
                // "Move"
                state.player.insert(future, at: state.player.startIndex)
                
                if future != state.food {
                    state.player.removeLast()
                } else {
                    return .merge(.send(.spawnFood), .send(.checkScore))
                }
                
                return .none
            case .canvas(let size):                
                state.width = max(
                    Int(size.width.rounded(.up)) / Snake.cellSize, 
                    Snake.minWidth
                )
                state.height = max(
                    Int(size.height.rounded(.up)) / Snake.cellSize, 
                    Snake.minHeight
                )
                
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
                    return await .findNextFoodCoordinate(TaskResult<Coordinate> {
                        try await coordinateGenerator.findOpenCoordinate(width, height, player)
                    })
                }
                .cancellable(id: SpawnFoodID.self)
            case .findNextFoodCoordinate(.success(let coordinate)):
                state.food = coordinate
                
                return .none
            case .findNextFoodCoordinate(.failure):
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
                
                return .merge(.send(.spawnFood), .send(.checkScore))
            case .checkScore:
                return .task { [player = state.player] in
                    let highscore = await highScoreClient.getHighScore()
                    
                    if highscore < player.count {
                        await highScoreClient.setHighScore(player.count)
                    }
                    
                    return .updateHighScore(highscore)
                }
            case .updateHighScore(let score):
                state.highscore = score
                return .none
            case .binding(_):
                return .none
            }   
        }
    }
}
