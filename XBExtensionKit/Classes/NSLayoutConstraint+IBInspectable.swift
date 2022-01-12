//
//  NSLayoutConstraint+IBInspectable.swift
//  TopNews
//
//  Created by leiyuncun on 2018/12/1.
//  Copyright © 2018 xb. All rights reserved.
//

import Foundation

private var horizontal_key = 100
private var vertical_key = 200

public extension NSLayoutConstraint {
    
    /// 水平方向约束
    @IBInspectable var verticalConstant: CGFloat {
        
        set {
            
            constant = KScaleV(verticalConstant)
            objc_setAssociatedObject(self, &vertical_key, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            
            if let vc = objc_getAssociatedObject(self, &vertical_key) as? CGFloat {
                return vc
            }
            return constant
        }
    }
    
    /// 竖直方向约束
    @IBInspectable var horizontalConstant: CGFloat {
        
        set {
            
            constant = KScaleH(horizontalConstant)
            objc_setAssociatedObject(self, &horizontal_key, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            
            if let hc = objc_getAssociatedObject(self, &horizontal_key) as? CGFloat {
                return hc
            }
            return constant
        }
    }
    
    
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    @discardableResult
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
    
}

var MarginDic: [String: CGFloat] = [
    "viewToEdge": 13
]
public extension NSLayoutConstraint {
    /// 设置改属性，将会覆盖重新复制约束中constant的值
    @IBInspectable var marginConstant: String {
        
        set {
            if let margin = MarginDic[newValue] {
                constant = margin
            }
           
        }
        get {
            return "\(constant)"
        }
    }
}


private func KScaleH(_ c: CGFloat) -> CGFloat {
    return UIScreen.main.bounds.width / 375 * c
}

private func KScaleV(_ c: CGFloat) -> CGFloat {
    return UIScreen.main.bounds.height / 667 * c
}


