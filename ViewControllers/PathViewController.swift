//
//  PathViewController.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 24.02.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import UIKit

class PathViewController: UIViewController {

    var path = StationPath()
    @IBOutlet weak var scrollView: UIScrollView!
    private var indent: CGFloat = 16
    private var pathView = UIView()
    private var linesWidth: CGFloat = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let strokeWidth = linesWidth / 2
        var previusLine = -1
        var currentY = indent
        var date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        for stationId in path {
            let station = MetroData.shared.stations[stationId.id]
            let color = MetroData.shared.lines[station!.lineId - 1].color
            var stroke: UIView?
            
            if previusLine == station?.lineId {
                let connection = UIView(frame: CGRect(x: indent*2 + linesWidth/2 + 50, y: currentY - indent - strokeWidth, width: linesWidth, height: indent*2))
                connection.backgroundColor = UIColor(red: CGFloat(color.r/255), green: CGFloat(color.g/255), blue: CGFloat(color.b/255), alpha: 1.0)
                pathView.addSubview(connection)
                if !stationId.change {
                    stroke = UIView(frame: CGRect(x: strokeWidth, y: strokeWidth, width: linesWidth*2 - strokeWidth*2, height: linesWidth*2 - strokeWidth*2))
                    stroke!.layer.cornerRadius = linesWidth - strokeWidth
                    stroke!.backgroundColor = view.backgroundColor
                }
            } else if previusLine != -1 { //else (except first station)
                let changeLineLabel = UILabel(frame: CGRect(x: indent*2 + linesWidth*2, y: currentY, width: 256, height: linesWidth*2))
                changeLineLabel.text = "Сделайте пересадку"
                pathView.addSubview(changeLineLabel)
                currentY += indent + linesWidth*2
            }
            
            date = date.addingTimeInterval(TimeInterval(stationId.time)) //update time
            
            let timeLabel = UILabel(frame: CGRect(x: indent, y: currentY, width: 50, height: linesWidth*2))
            timeLabel.text = formatter.string(from: date) //format as time
            
            let circle = UIView(frame: CGRect(x: indent*2 + 50, y: currentY, width: linesWidth*2, height: linesWidth*2))
            circle.layer.cornerRadius = linesWidth
            circle.backgroundColor = UIColor(red: CGFloat(color.r/255), green: CGFloat(color.g/255), blue: CGFloat(color.b/255), alpha: 1.0)
            
            if let stroke = stroke { circle.addSubview(stroke) }
            let text = UILabel(frame: CGRect(x: indent*3 + linesWidth*2 + 50, y: currentY, width: UIScreen.main.bounds.width - (indent*4 + linesWidth*2 + 50), height: linesWidth*2))
            text.text = station?.name.ru.capitalized
            
            previusLine = station!.lineId
            currentY += indent + linesWidth*2
            
            pathView.addSubview(timeLabel)
            pathView.addSubview(circle)
            pathView.addSubview(text)
            
        }
        pathView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: currentY)
        scrollView.addSubview(pathView)
        scrollView.contentSize = pathView.frame.size
    }
}
