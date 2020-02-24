//
//  SelectMenuView.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 22.02.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import UIKit

protocol SelectMenuDelegate {
    func selectedMenu(sender: SelectorView) -> Void
}

class SelectMenuView: UIView {

    var spaceBetween: CGFloat = 40
    var delegate: SelectMenuDelegate?
    var fontSize: CGFloat = 40
    var strokeWidth: CGFloat = 5
    private var fromSelector = SelectorView()
    private var toSelector = SelectorView()
    private var newObject = true
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fromSelector.frame = CGRect(x: 0, y: 0, width: frame.size.width/2 - spaceBetween/2, height: frame.size.height)
        fromSelector.text = "from"
        fromSelector.color = .white
        fromSelector.fontSize = fontSize
        fromSelector.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        fromSelector.fontColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        fromSelector.strokeWidth = strokeWidth
        
        toSelector.frame = CGRect(x: frame.size.width/2 + spaceBetween/2, y: 0, width: frame.size.width/2 - spaceBetween/2, height: frame.size.height)
        toSelector.fontSize = fontSize
        toSelector.strokeWidth = strokeWidth
        
        toSelector.color = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        toSelector.fontColor = .white
        toSelector.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        toSelector.text = "to"
        
        if !newObject { return }
        newObject = false
        
        fromSelector.delegate = self
        fromSelector.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        
        toSelector.delegate = self
        toSelector.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        
        toSelector.accessibilityIdentifier = "toSelector"
        fromSelector.accessibilityIdentifier = "fromSelector"
        addSubview(fromSelector)
        addSubview(toSelector)
    }
}
extension SelectMenuView: SelectorDelegate{
    func OptionSelected(sender: SelectorView) {
        delegate?.selectedMenu(sender: sender)
    }
}
