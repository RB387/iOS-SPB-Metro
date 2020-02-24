//
//  StationView.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 22.02.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import UIKit

protocol StationDelegate {
    func stationSelected(sender: StationView) -> Void
}

class StationView: UIView {
    var delegate: StationDelegate?
    var color: UIColor = .white
    var lineWidth: CGFloat = 10
    var stationId: Int?
    var strokeWidth: CGFloat = 10
    var strokeScale: CGFloat = 1.5
    private var newObject: Bool = true
    private let stroke = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        stroke.frame = CGRect(x: strokeWidth, y: strokeWidth, width: lineWidth*strokeScale - strokeWidth*2, height: lineWidth*strokeScale - strokeWidth*2)
        stroke.backgroundColor = color
        stroke.layer.cornerRadius = (lineWidth*strokeScale - strokeWidth*2)/2
        layer.cornerRadius = lineWidth*strokeScale/2
        
        if !newObject { return }
        newObject = false
        addSubview(stroke)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.stationSelected(sender: self)
    }
    
}
