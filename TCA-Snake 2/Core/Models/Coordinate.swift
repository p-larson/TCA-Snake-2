//
//  Coordinate.swift
//  TCA-Snake 2
//
//  Created by Peter Larson on 4/9/23.
//

import Foundation

typealias Coordinate = Vector

extension Coordinate {
    var x: Int { dx }
    var y: Int { dy }
    
    init(x: Int, y: Int) {
        self.init(x, y)
    }
    
    func isInBounds(_ width: Int, _ height: Int) -> Bool {
        return (0 ..< width).contains(x) && (0 ..< height).contains(y)
    }
}
