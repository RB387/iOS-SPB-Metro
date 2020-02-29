//
//  Model.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 19.02.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import Foundation
import UIKit

func RestorePath(_ parents: [Int], from: Int, to: Int) -> [Int]{
    //Initialize variables
    var backwardStation = to
    var path: [Int] = [backwardStation]
    while backwardStation != from { //step back while backward station isnt start point
        backwardStation = parents[backwardStation - 1] //get prev station
        path.append(backwardStation) //append to path
    }
    return path.reversed() //return path from begging to finish (thats why reversed)
}

//Find fastest way to station. Dijkstra's algorithm. Complexity O(N^2)
func FindPath(from: Int, to: Int) -> [Int] {
    let N = MetroData.shared.stations.count //get count of all staions
    var weight = [Int : (weight: Int, visited: Bool)]() //initialize weights
    for idx in 0..<N { weight[idx + 1] = (weight: Int.max, visited: false) } //fill weights (Int.max cuz +infinity)
    var parents: [Int] = Array.init(repeating: from, count: N) //array of parents to restore path
    weight[from]?.weight = 0 //null start point
    for _ in 0..<N { //iterate N times
        //get only unvisited stations and sort them
        let unvisited = weight.filter { !$0.value.visited }.sorted { $0.value.weight < $1.value.weight }
        // if empty (what we dont expect)
        if unvisited.isEmpty { print("ERROR"); return [] }
        // Iterate every bridge from current station
        for station in MetroData.shared.stations[unvisited.first!.key]!.edges {
            //if we found faster way to point, save it
            if station.time + unvisited.first!.value.weight < weight[station.to]!.weight {
                //save weight
                weight[station.to]!.weight = station.time + unvisited.first!.value.weight
                //save info about parent
                parents[station.to - 1] = unvisited.first!.key
            }
        }
        //check current station as visited
        weight[unvisited.first!.key]?.visited = true
    }
    return RestorePath(parents, from: from, to: to)
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

extension UIColor {

    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}
