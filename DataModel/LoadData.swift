//
//  LoadData.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 18.02.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import Foundation

class MetroData {
    
    static let shared = MetroData()
    private var fetched: Bool = false
    var stations = [Int : Station]()
    var lines = [Line]()
    var multiPoints = [MultiPoint]()
    var multiPointIds = [Int]()
    
    
    func FetchData(){
        if fetched { return }
        
        if let pathJson = Bundle.main.url(forResource: "data", withExtension: "json"),
            let data = try? Data(contentsOf: pathJson),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any]{
            
                for multiPoint in json["multiPoints"] as! [[String : Any]]{
                    let coordsPoint = multiPoint["coords"] as! [String : NSNumber]
                    multiPoints.append(MultiPoint(ids: multiPoint["id"] as! [Int], coords: (x: coordsPoint["x"]!.floatValue, y: coordsPoint["y"]!.floatValue)))
                    multiPointIds += multiPoint["id"] as! [Int]
                }
                
                for oneStation in json["stations"] as! [[String : Any]]{
                    if let id = oneStation["id"] as? Int,
                        let coords = oneStation["coords"] as? [String : NSNumber],
                        let multi = oneStation["multi"] as? Bool,
                        let name = oneStation["name"] as? [String : String],
                        let titleCoords = oneStation["title"] as? [String : NSNumber],
                        let edges = oneStation["edges"] as? [[String : Int]],
                        let lineId = oneStation["line"] as? Int {
                            var edgesArray = [(time: Int, to: Int)]()
                            for edge in edges { edgesArray.append((time: edge["time"]!, to: edge["id"]! )) }
                            let station = Station(id: id,
                                            coords: (x: coords["x"]!.floatValue, y: coords["y"]!.floatValue),
                                            titleCoords: (x: titleCoords["x"]!.floatValue, y: titleCoords["y"]!.floatValue),
                                            multi: multi, name: (ru: name["ru_RU"]!, en: name["en_EN"]!),
                                            edges: edgesArray, lineId: lineId)
                            stations[id] = station
                    }
                    else{ fatalError("DATA FILE IS CORRUPT") }
                }
                
                var colors = [(r: Float, g: Float, b: Float)]()
                for color in json["colors"] as! [[String:NSNumber]] {
                    colors.append((r: color["r"]!.floatValue, g: color["g"]!.floatValue, b: color["b"]!.floatValue))
                }
                
                for (idx, line) in (json["lines"] as! [ [ [String : Int] ] ]).enumerated() {
                    var linePaths = [(from: Int, to: Int)]()
                    for oneStation in line {
                        linePaths.append((from: oneStation["from"]!, to: oneStation["to"]!))
                    }
                    lines.append(Line(id: idx + 1, path: linePaths, color: colors[idx]))
                }
        } else { fatalError("DATA FILE IS CORRUPT") }
        fetched = true
    }
    
}
