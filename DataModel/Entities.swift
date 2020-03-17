//
//  DataModel.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 18.02.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import Foundation

struct Station {
    var id: Int
    var coords: (x: Float, y: Float)
    var titleCoords: (x: Float, y: Float)
    var multi: Bool
    var name: (ru: String, en: String)
    var edges: [(time: Int, to: Int)]
    var lineId: Int
}

struct Line {
    var id: Int
    var path: [(from: Int, to: Int)]
    var color: (r: Float, g: Float, b: Float)
}

struct MultiPoint {
    var ids: [Int]
    var coords: (x: Float, y: Float)
}
