//
//  UILabel+IBInspectable.swift
//  TopNews
//
//  Created by leiyuncun on 2018/12/1.
//  Copyright © 2018 xb. All rights reserved.
//

import Foundation

private var fitFontSizeKey = 300

extension UILabel {
    
    @IBInspectable var fitFontSize: CGFloat {
        
        set {
            
            font = UIFont(name: font.fontName, size: KScaleH(fitFontSize))
            objc_setAssociatedObject(self, &fitFontSizeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            
            if let fs = objc_getAssociatedObject(self, &fitFontSizeKey) as? CGFloat {
                return fs
            }
            return font.pointSize
        }
    }
}


private func KScaleH(_ c: CGFloat) -> CGFloat {
    return UIScreen.main.bounds.width / 414 * c
}
