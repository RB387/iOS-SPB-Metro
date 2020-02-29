//
//  Model.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 19.02.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import Foundation

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
        //get only unvisited stations and find min
        let unvisited = weight.filter { !$0.value.visited }.min { $0.value.weight < $1.value.weight }
        guard (unvisited != nil) else { return [] }
        // Iterate every bridge from current station
        for station in MetroData.shared.stations[unvisited!.key]!.edges {
            //if we found faster way to point, save it
            if station.time + unvisited!.value.weight < weight[station.to]!.weight {
                //save weight
                weight[station.to]!.weight = station.time + unvisited!.value.weight
                //save info about parent
                parents[station.to - 1] = unvisited!.key
            }
        }
        //check current station as visited
        weight[unvisited!.key]?.visited = true
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
