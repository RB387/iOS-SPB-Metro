//
//  SelectorView.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 22.02.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import UIKit

protocol SelectorDelegate {
    func OptionSelected(sender: SelectorView) -> Void
}

class SelectorView: UIView {

    var text: String = "Selector View"
    var delegate: SelectorDelegate?
    var color: UIColor = .white
    var fontSize: CGFloat = 20
    var fontColor: UIColor = .black
    var strokeWidth: CGFloat = 5
    private var newObject: Bool = true
    private var stroke = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        stroke.frame = CGRect(x: strokeWidth, y: strokeWidth, width: frame.size.width - strokeWidth*2, height: frame.size.height - strokeWidth*2)
        
        stroke.text = text
        
        stroke.font = UIFont.systemFont(ofSize: round(fontSize))
        
        stroke.textColor = fontColor
        stroke.backgroundColor = color
        
        layer.cornerRadius = frame.size.height * 0.5
        
        stroke.layer.cornerRadius = stroke.frame.size.height * 0.5
        
        
        if !newObject { return }
        newObject = false
        
        stroke.clipsToBounds = true
        
        stroke.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        stroke.textAlignment = .center
        
        addSubview(stroke)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.OptionSelected(sender: self)
    }

}
