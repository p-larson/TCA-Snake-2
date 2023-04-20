//
//  Models.swift
//  TCA-Snake 2
//
//  Created by Peter Larson on 4/9/23.
//

import Foundation

struct Vector: Equatable, Hashable, CustomDebugStringConvertible {
    static func ==(lhs: Vector, rhs: Vector) -> Bool {
        lhs.dx == rhs.dx && rhs.dy == lhs.dy
    }

    
    let dx, dy: Int
    
    init(dx: Int, dy: Int) {
        self.dx = dx
        self.dy = dy
    }
    
    init(_ dx: Int, _ dy: Int) {
        self.dx = dx
        self.dy = dy
    }
    
    internal static let zero = Vector(0, 0)
    internal static let down = Vector(0, 1)
    internal static let up = Vector(0, -1)
    internal static let left = Vector(-1, 0)
    internal static let right = Vector(1, 0)
    
    static let start = Coordinate(0, 0)
    
    var debugDescription: String {
        "(\(dx), \(dy))"
    }
    
    enum Direction: Equatable, CaseIterable, CustomDebugStringConvertible {
        case zero, down, up, left, right
        
        var vector: Vector {
            switch self {
            case .zero: return Vector(0, 0)
            case .down: return Vector(0, -1)
            case .up: return Vector(0, 1)
            case .left: return Vector(-1, 0)
            case .right: return Vector(1, 0)
            }
        }
        
        var debugDescription: String {
            vector.debugDescription
        }
    }
}

extension Vector {
    static func * (lhs: Vector, rhs: Int) -> Vector {
        return Self(lhs.dx * rhs, lhs.dy * rhs)
    }
}

extension Vector {
    static func - (lhs: Vector, rhs: Vector) -> Vector {
        return Self(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }
    
    static func + (lhs: Vector, rhs: Vector) -> Vector {
        return Self(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }
}

extension Vector {
    static func - (lhs: Vector, rhs: Direction) -> Vector {
        return lhs - rhs.vector
    }
    
    static func + (lhs: Vector, rhs: Direction) -> Vector {
        return lhs + rhs.vector
    }
}
