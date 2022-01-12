//
//  UIView+IBInspectable.swift
//  TopNews
//
//  Created by leiyuncun on 2018/12/1.
//  Copyright © 2018 xb. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    
    @IBInspectable var ibCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            clipsToBounds = true
        }
    }
    
    @IBInspectable var ibBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var ibBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
}

public extension UIView {
    
    /// 设置多个圆角
    ///
    /// - Parameters:
    ///   - cornerRadii: 圆角幅度
    ///   - roundingCorners: UIRectCorner(rawValue: (UIRectCorner.topRight.rawValue) | (UIRectCorner.bottomRight.rawValue))
    public func filletedCorner(_ cornerRadii:CGSize,_ roundingCorners:UIRectCorner, borderWidth: CGFloat = 0, borderColor: CGColor = UIColor.clear.cgColor)  {
        let fieldPath = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii:cornerRadii )
        let fieldLayer = CAShapeLayer()
        fieldLayer.frame = bounds
        fieldLayer.path = fieldPath.cgPath
        fieldLayer.borderWidth = borderWidth
        fieldLayer.borderColor = borderColor
        self.layer.mask = fieldLayer
    }
}
