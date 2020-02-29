//
//  MapView.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 24.02.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import UIKit

protocol MapViewDelegate {
    func touchesEnded() -> Void
}

class MapView: UIView {

    var delegate: MapViewDelegate?
    var strokeScale: CGFloat = 10
    var strokeWidth: CGFloat = 10
    var lineWidth: CGFloat = 10
    var color: UIColor = .white
    var scale: Float = 10
    
    func drawStation(_ idx: Int, delegate: StationDelegate) -> (circle: StationView, title: UILabel, color: UIColor){
        var station = MetroData.shared.stations[idx]!.coords
        station.x *= scale; station.y *= scale
        let line = MetroData.shared.lines[MetroData.shared.stations[idx]!.lineId - 1]
        let stationUI = StationView(frame: CGRect(x: CGFloat(station.x) - lineWidth*strokeScale/2, y: CGFloat(station.y) - lineWidth*strokeScale/2, width: lineWidth*strokeScale, height: lineWidth*strokeScale))
        stationUI.strokeScale = strokeScale
        stationUI.strokeWidth = strokeWidth
        stationUI.lineWidth = lineWidth
        stationUI.backgroundColor = color
        stationUI.color = UIColor(red: CGFloat(line.color.r/255), green: CGFloat(line.color.g/255), blue: CGFloat(line.color.b/255), alpha: 1.0)
        stationUI.stationId = idx
        stationUI.delegate = delegate
        
        let title = UILabel(frame: CGRect(x: CGFloat(station.x) + lineWidth/2 + strokeWidth, y: CGFloat(station.y) - lineWidth/2, width: 10 * CGFloat(scale), height: CGFloat(scale)))
        title.textAlignment = .left
        title.font = UIFont.boldSystemFont(ofSize: CGFloat(scale))
        title.text = MetroData.shared.stations[idx]!.name.ru.capitalized
        
        return (circle: stationUI, title: title, color: stationUI.color)
    }
    
    func drawLine(_ idx: Int) -> [String: (layer: CAShapeLayer, color: UIColor)] {
        var lines = [String: (layer: CAShapeLayer, color: UIColor)]()
        let line = MetroData.shared.lines[idx]
        for station in line.path{
            var lhs = MetroData.shared.stations[station.from]!.coords
            lhs.x *= scale; lhs.y *= scale
            var rhs = MetroData.shared.stations[station.to]!.coords
            rhs.x *= scale; rhs.y *= scale
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: CGFloat(lhs.x), y: CGFloat(lhs.y)))
            path.addLine(to: CGPoint(x: CGFloat(rhs.x), y: CGFloat(rhs.y)))
            let shapeLayer = CAShapeLayer()
            
            shapeLayer.path = path.cgPath
            let color = UIColor(red: CGFloat(line.color.r/255), green: CGFloat(line.color.g/255), blue: CGFloat(line.color.b/255), alpha: 1.0)
            shapeLayer.strokeColor = color.cgColor
            shapeLayer.lineWidth = lineWidth
            lines["\(station.from) \(station.to)"] = (layer: shapeLayer, color: color)
        }
        return lines
    }
    
    func drawMultiPoint(_ idx: Int) -> MultiPointView{
        let multiPoint = MetroData.shared.multiPoints[idx]
        var coords = multiPoint.coords
        coords.x *= scale; coords.y *= scale
        let width = 2*(lineWidth + strokeWidth)*2.5
        let height = CGFloat(multiPoint.ids.count%2 + 1)*CGFloat(lineWidth + strokeWidth)*2.5
        let pointX = CGFloat(coords.x) - width/4
        let pointY = CGFloat(coords.y) - height/CGFloat(multiPoint.ids.count) + lineWidth/2 - strokeWidth
        let point = MultiPointView(frame: CGRect(x: pointX, y: pointY, width: width, height: height))
        point.strokeWidth = strokeWidth
        point.color = color
        point.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        point.layer.cornerRadius = point.frame.height * 0.5
        return point
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchesEnded()
    }
}
