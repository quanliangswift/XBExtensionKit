//
//  UIColor+BaseKit.swift
//  TopNews
//
//  Created by leiyuncun on 2019/9/2.
//  Copyright © 2019 xb. All rights reserved.
//

import Foundation


public extension UIColor {
    
    func hexString(prefix:String = "") -> String {
        let rgbFloat = self.rgba()
        
        let result = self.string(of: rgbFloat.r) + self.string(of: rgbFloat.g) + self.string(of: rgbFloat.b)
        return prefix + result.uppercased()
    }
    
    private func string(of component:Int) -> String {
        let result = String(format: "%x",  component)
        let count = result.count
        if count == 0 {
            return "00"
        }else if count == 1 {
            return "0" + result
        }else {
            return result
        }
    }
    
    func rgba() -> (r: Int, g: Int, b: Int, a: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        r = r * 255
        g = g * 255
        b = b * 255
        
        return (Int(r),Int(g),Int(b),a)
    }
}
