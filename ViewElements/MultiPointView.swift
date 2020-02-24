//
//  MultiPointUI.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 22.02.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import UIKit

class MultiPointView: UIView {
    
    var lineWidth: CGFloat = 10
    var strokeWidth: CGFloat = 10
    var strokeScale: CGFloat = 1.5
    var color: UIColor = .white
    private var newObject: Bool = true

    override func layoutSubviews(){
        super.layoutSubviews()
        
        let stroke = UIView(frame: CGRect(x: strokeWidth, y: strokeWidth, width: layer.frame.width - strokeWidth*2, height: layer.frame.height - strokeWidth*2))
        stroke.layer.cornerRadius = stroke.frame.height * 0.5
        stroke.backgroundColor = color
        
        if !newObject { return }
        newObject = false
        addSubview(stroke)
    }

}
