//
//  UIViewExtBoard.swift
//  TopNews
//
//  Created by leiyuncun on 2018/12/18.
//  Copyright © 2018 xb. All rights reserved.
//

import Foundation

//为 UIView 扩展添加边框功能
public extension UIView {
    
    //画线
    private func drawBorder(rect:CGRect,color:UIColor){
        let line = UIBezierPath(rect: rect)
        let lineShape = CAShapeLayer()
        lineShape.path = line.cgPath
        lineShape.fillColor = color.cgColor
        self.layer.addSublayer(lineShape)
    }
    
    //设置右边框
    @discardableResult
    public func rightBorder(_ width: CGFloat, color: UIColor) -> UIView {
        let rect = CGRect(x: 0, y: self.frame.size.width - width, width: width, height: self.frame.size.height)
        drawBorder(rect: rect, color: color)
        return self
    }
    //设置左边框
    @discardableResult
    public func leftBorder(_ width: CGFloat, color: UIColor) -> UIView {
        let rect = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        drawBorder(rect: rect, color: color)
        return self
    }
    
    //设置上边框
    @discardableResult
    public func topBorder(_ width: CGFloat, color: UIColor) -> UIView {
        let rect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        drawBorder(rect: rect, color: color)
        return self
    }
    
    
    //设置下边框
    @discardableResult
    public func bottomBorder(_ width: CGFloat, color: UIColor) -> UIView {
        let rect = CGRect(x: 0, y: self.frame.size.height-width, width: self.frame.size.width, height: width)
        drawBorder(rect: rect, color: color)
        return self
    }
}
