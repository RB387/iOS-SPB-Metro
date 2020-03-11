//
//  MarkView.swift
//  SPBMetro
//
//  Created by Nikita Robertson on 01.03.2020.
//  Copyright © 2020 Nikita Robertson. All rights reserved.
//

import UIKit

class MarkView: UIImageView {
    
    var markCharacter: String = "A"
    var fontColor: UIColor = .white
    var fontSize: CGFloat = 20
    private let characterView = UILabel()
    private var newObject: Bool = true
    
    override func layoutSubviews() {
        super.layoutSubviews()
        characterView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        characterView.text = markCharacter
        characterView.textAlignment = .center
        characterView.font = UIFont.systemFont(ofSize: fontSize)
        characterView.textColor = fontColor
        
        
        if !newObject { return }
        newObject = false
        characterView.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        addSubview(characterView)
    }

}
