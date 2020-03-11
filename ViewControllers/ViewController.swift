//
//  ViewController.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 18.02.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //-MARK- UI ELEMENTS
    private let selectMenu = SelectMenuView()
    private let markFrom = MarkView()
    private let markTo = MarkView()
    @IBOutlet weak var map: MapView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var showRouteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    //-MARK- Settings for UI elements
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
    private var previusStation = StationView()
    private var alpha: CGFloat = 0.2
    private var menuConstraint = 8
    //data
    private var pathBuilded: Bool = false
    private var path: StationPath = []
    //marks
    private var stationFrom: Int? = nil
    private var stationTo: Int? = nil
    
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
        configureUI()
        updateScale()
        centerMap()
    }
    
    @IBAction func showRouteClick(_ sender: Any) {
        performSegue(withIdentifier: "showPath", sender: showRouteButton)
    }
    
    @IBAction func cancelButtonClick(_ sender: Any) {
        resetMap()
        UIView.animate(withDuration: 0.3){
            self.showRouteButton.alpha = 0
            self.cancelButton.alpha = 0
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showPath" else { return }
        guard let destination = segue.destination as? PathViewController else { return }
        destination.path = path
    }
}

extension ViewController {
    //-MARK- Configure methods
    func setupParams(){
        lineWidth = scale
        strokeWidth = scale/4
        menuStrokeWidth = scale/8
        menuWidth = scale*12
        menuHeight = menuWidth/4
        menuFontSize = menuHeight/4
    }
    
    func configureSubviews(){
        // -MARK- ScrollView
        scrollView.contentSize = map.frame.size
        scrollView.minimumZoomScale = UIScreen.main.bounds.size.width / map.frame.size.width
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = scrollView.minimumZoomScale
        // -MARK- Map
        map.strokeScale = strokeScale
        map.strokeWidth = strokeWidth
        map.lineWidth = lineWidth
        map.color = view.backgroundColor ?? .white
        map.backgroundColor = view.backgroundColor
        map.scale = Float(scale)
        map.delegate = self
        // -MARK- Button
        let screenHeight = UIScreen.main.bounds.height
        showRouteButton.layer.cornerRadius = screenHeight / 24
        showRouteButton.alpha = 0
        cancelButton.layer.cornerRadius = screenHeight / 32
        cancelButton.alpha = 0
        
    }

    
    func configureUI(){
        //-MARK- Selected stations marks
        for mark in [(obj: markTo, img: "EllipseTo", char: "B"), (obj: markFrom, img: "EllipseFrom", char: "A")]{
            mark.obj.frame = CGRect(x: 0, y: 0, width: menuHeight, height: menuHeight)
            mark.obj.image = UIImage(named: mark.img)
            mark.obj.markCharacter = mark.char
            mark.obj.fontSize = menuFontSize * 1.25
            mark.obj.alpha = 0
            map.addSubview(mark.obj)
        }
        // -MARK- SelectMenu
        selectMenu.frame = CGRect(x: 0, y: 0, width: menuWidth, height: menuHeight)
        selectMenu.isHidden = true
        selectMenu.alpha = 0
        selectMenu.fontSize = CGFloat(menuFontSize)
        selectMenu.strokeWidth = menuStrokeWidth
        selectMenu.color = view.backgroundColor ?? .white
        selectMenu.spaceBetween = lineWidth
        selectMenu.delegate = self
        //
        map.addSubview(selectMenu)
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
        if scrollView.zoomScale < scrollView.minimumZoomScale || scrollView.zoomScale > scrollView.maximumZoomScale { return }
        let width = menuWidth*(1/scrollView.zoomScale)
        selectMenu.frame = CGRect(x: selectMenu.frame.minX+((selectMenu.frame.width - width)/2), y: selectMenu.frame.minY, width: width, height: menuHeight*(1/scrollView.zoomScale))
        selectMenu.fontSize = menuFontSize * (1/scrollView.zoomScale)
        selectMenu.strokeWidth = menuStrokeWidth * (1/scrollView.zoomScale)
        let markWidth = menuHeight*(1/scrollView.zoomScale)
        for mark in [markTo, markFrom] {
            mark.frame = CGRect(x: mark.frame.minX+((mark.frame.width - markWidth)/2), y: mark.frame.minY + ((mark.frame.height - markWidth)), width: markWidth, height: markWidth)
            mark.fontSize = menuFontSize * 1.25 * (1/scrollView.zoomScale)
        }
    }
    
    func centerMap(){
        let horizontalSpace = map.frame.size.width < scrollView.bounds.width ? (scrollView.bounds.width - map.frame.size.width) / 2 : 0
        let verticalSpace = map.frame.size.height < scrollView.bounds.height ? (scrollView.bounds.height - map.frame.size.height) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
    }
    
    func buildPath(){
        guard let pathFrom = stationFrom, let pathTo = stationTo else { return }
        
        path = FindPath(from: pathFrom, to: pathTo)
        var edges = [CAShapeLayer]()
        
        for stationId in 0..<(path.count-1){
            if let edge = lines["\(path[stationId].id) \(path[stationId + 1].id)"] ?? lines["\(path[stationId + 1].id) \(path[stationId].id)"] {
                edges.append(edge.layer)
            }
        }
        
        for line in lines {
            if edges.contains(line.value.layer) { continue }
            line.value.layer.strokeColor = line.value.color.withAlphaComponent(alpha).cgColor
        }
        
        var ids = [Int]()
        for element in path { ids.append(element.id) }
        
        for station in stations {
            if ids.contains(station.key) { continue }
            station.value.circle.color = station.value.color.withAlphaComponent(alpha)
            station.value.circle.layoutSubviews()
            station.value.title.alpha = alpha
        }
        pathBuilded = true
        UIView.animate(withDuration: 0.2) { self.showRouteButton.alpha = 1
            self.cancelButton.alpha = 1
        }
    }
    
    func resetMap(){
        for line in lines {
            line.value.layer.strokeColor = line.value.color.cgColor
        }
        for station in stations {
            station.value.circle.color = station.value.color
            station.value.circle.layoutSubviews()
            station.value.title.alpha = 1
        }
        stationTo = nil; stationFrom = nil
        markTo.alpha = 0; markFrom.alpha = 0
        pathBuilded = false
    }
    
    func setMark(x: CGFloat, y: CGFloat, mark: MarkView) {
        mark.alpha = 0
        mark.frame.origin.x = x - mark.frame.size.width/2 + lineWidth/2 + strokeWidth
        mark.frame.origin.y = y - mark.frame.size.height
        UIView.animate(withDuration: 0.3){
            mark.alpha = 1
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
}

extension ViewController: StationDelegate{
    func stationSelected(sender: StationView) {
        if pathBuilded { return }
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
        case "toSelector":
            stationTo = previusStation.stationId
            setMark(x: previusStation.frame.minX, y: previusStation.frame.minY, mark: markTo)
        case "fromSelector":
            stationFrom = previusStation.stationId
            setMark(x: previusStation.frame.minX, y: previusStation.frame.minY, mark: markFrom)
        default: fatalError("No such identifier")
        }
        buildPath()
        hideMenu(animated: true)
    }
}

