//
//  ViewController.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 18.02.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var map: MapView!
    @IBOutlet weak var scrollView: UIScrollView!
    private let scale: CGFloat = 20
    private var lineWidth: CGFloat = 40
    private var menuFontSize: CGFloat = 20
    private var stations = [Int : (circle: StationView, title: UILabel, color: UIColor)]()
    private var lines = [String : (layer: CAShapeLayer, color: UIColor)]()
    private var strokeWidth: CGFloat = 10
    private let strokeScale: CGFloat = 1.5
    private var menuStrokeWidth: CGFloat = 2
    private var menuWidth: CGFloat = 200
    private var menuHeight: CGFloat = 50
    private var selectMenu = SelectMenuView()
    private var previusStation = StationView()
    private var alpha: CGFloat = 0.2
    
    private var stationFrom: Int? = nil
    private var stationTo: Int? = nil
    
    func setupParams(){
        lineWidth = scale
        strokeWidth = scale/4
        menuStrokeWidth = scale/8
        menuWidth = scale*8
        menuHeight = menuWidth/4
        menuFontSize = scale/2
    }
    
    func configureSubviews(){
        // -MARK- ScrollView
        scrollView.minimumZoomScale = UIScreen.main.bounds.size.width / map.frame.size.width
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = scrollView.minimumZoomScale
        // -MARK- Map
        map.strokeScale = strokeScale
        map.strokeWidth = strokeWidth
        map.lineWidth = lineWidth
        map.scale = Float(scale)
        map.delegate = self
    }
    
    func configureSelectMenu(){
        // -MARK- SelectMenu
        selectMenu = SelectMenuView(frame: CGRect(x: 0, y: 0, width: menuWidth, height: menuHeight))
        selectMenu.isHidden = true
        selectMenu.alpha = 0
        selectMenu.fontSize = CGFloat(menuFontSize)
        selectMenu.strokeWidth = menuStrokeWidth
        selectMenu.spaceBetween = lineWidth
        selectMenu.delegate = self
        //
        map.addSubview(selectMenu)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupParams()
        configureSubviews()
        MetroData.shared.FetchData()
        
        for i in 0..<MetroData.shared.lines.count{ lines.merge(dict: map.drawLine(i)) }
        for i in 1...MetroData.shared.stations.count { stations[i] = map.drawStation(i, delegate: self) }
        
        for line in lines.values{ map.layer.addSublayer(line.layer) }
        for i in 0..<MetroData.shared.multiPoints.count { map.addSubview(map.drawMultiPoint(i)) }
        for station in stations.values{ map.addSubview(station.circle); map.addSubview(station.title) }
        configureSelectMenu()
        updateScale()
        centerMap()
    }
}

// -MARK- Logic of elements
extension ViewController {
    func hideMenu(animated: Bool){
        if !animated { selectMenu.alpha = 0 }
        UIView.animate(withDuration: 0.3, animations: {
            self.selectMenu.alpha = 0
            self.previusStation.strokeWidth = self.strokeWidth
            self.previusStation.layoutSubviews()
        })
    }
    func updateScale(){
        if scrollView.zoomScale < scrollView.minimumZoomScale { return }
        let width = menuWidth*(1/scrollView.zoomScale)
        selectMenu.frame = CGRect(x: selectMenu.frame.minX+((selectMenu.frame.width - width)/2), y: selectMenu.frame.minY, width: width, height: menuHeight*(1/scrollView.zoomScale))
        selectMenu.fontSize = menuFontSize * (1/scrollView.zoomScale)
        selectMenu.strokeWidth = menuStrokeWidth * (1/scrollView.zoomScale)
    }
    
    func centerMap(){
        let centerOffsetX = (scrollView.contentSize.width - scrollView.frame.size.width) / 2
        let centerOffsetY = (scrollView.contentSize.height - scrollView.frame.size.height) / 2
        let centerPoint = CGPoint(x: centerOffsetX, y: centerOffsetY)
        scrollView.setContentOffset(centerPoint, animated: true)
    }
    
    func buildPath(){
        guard let pathFrom = stationFrom, let pathTo = stationTo else { return }
        
        let path = FindPath(from: pathFrom, to: pathTo)
        var edges = [CAShapeLayer]()
        
        for stationId in 0..<(path.count-1){
            print(stationId)
            if let edge = lines["\(path[stationId]) \(path[stationId + 1])"] ?? lines["\(path[stationId + 1]) \(path[stationId])"] {
                edges.append(edge.layer)
            }
        }
        
        for line in lines {
            if edges.contains(line.value.layer) { continue }
            line.value.layer.strokeColor = line.value.color.withAlphaComponent(alpha).cgColor
        }
        
        for station in stations {
            if path.contains(station.key) { continue }
            station.value.circle.color = station.value.color.withAlphaComponent(alpha)
            station.value.circle.layoutSubviews()
            station.value.title.alpha = alpha
        }
        
    }
    
}

extension ViewController: MapViewDelegate{
    func touchesEnded() {
        hideMenu(animated: true)
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return map
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateScale()
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale < scrollView.minimumZoomScale * 1.01 { centerMap() }
    }
}

extension ViewController: StationDelegate{
    func stationSelected(sender: StationView) {
        hideMenu(animated: true)
        previusStation.strokeWidth = strokeWidth
        let menuX = sender.frame.minX - selectMenu.frame.size.width/2 + lineWidth/2 + strokeWidth
        let menuY = sender.frame.minY
        selectMenu.frame = CGRect(x: menuX, y: menuY, width: selectMenu.frame.size.width, height: selectMenu.frame.size.height)
        selectMenu.isHidden = false
        previusStation = sender
        UIView.animate(withDuration: 0.3, animations: {
            self.previusStation.strokeWidth = self.strokeWidth*2
            self.previusStation.layoutSubviews()
            self.selectMenu.alpha = 1
        })
    }
}

extension ViewController: SelectMenuDelegate {
    func selectedMenu(sender: SelectorView) {
        switch sender.accessibilityIdentifier {
        case "toSelector": stationTo = previusStation.stationId
        case "fromSelector": stationFrom = previusStation.stationId
        default: print("ERROR")
        }
        buildPath()
        hideMenu(animated: true)
    }
}

