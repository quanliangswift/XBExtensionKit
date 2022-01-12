//
//  UIImageView+Corner.swift
//  TopNews
//  给UIView和UIImageView加圆角的扩展，不会出现离屏渲染
//  Created by xb on 2017/8/14.
//  Copyright © 2017年 xb. All rights reserved.
//

import UIKit

func roundbyunit(num: Double, unit: inout Double) -> Double {
    let remain = modf(num, &unit)
    if (remain > unit / 2.0) {
        return ceilbyunit(num: num, unit: &unit)
    } else {
        return floorbyunit(num: num, unit: &unit)
    }
}
 func ceilbyunit(num: Double, unit: inout Double) -> Double {
    return num - modf(num, &unit) + unit
}

 func floorbyunit(num: Double, unit: inout Double) -> Double {
    return num - modf(num, &unit)
}
 func pixel(num: Double) -> Double {
    var unit: Double
    switch Int(UIScreen.main.scale) {
    case 1: unit = 1.0 / 1.0
    case 2: unit = 1.0 / 2.0
    case 3: unit = 1.0 / 3.0
    default: unit = 0.0
    }
    
    return roundbyunit(num: num, unit: &unit)
}
public extension UIView {
    // view添加圆角
    @objc func xb_addCorner(radius: CGFloat) {
        self.xb_addCorner(radius: radius, borderWidth: 1, backgroundColor: UIColor.clear, borderColor: UIColor.black)
    }
    func xb_addCorner(radius: CGFloat,
                      
                      borderWidth: CGFloat,
                      
                      backgroundColor: UIColor,
                      
                      borderColor: UIColor) {
        
        let imageView = UIImageView(image: xb_drawRectWithRoundedCorner(radius: radius,
                                                                        
                                                                        borderWidth: borderWidth,
                                                                        
                                                                        backgroundColor: backgroundColor,
                                                                        
                                                                        borderColor: borderColor))
        
        self.insertSubview(imageView, at: 0)
        
    }
    
    func xb_drawRectWithRoundedCorner( radius: CGFloat,
                                      borderWidth: CGFloat,
                                      backgroundColor: UIColor,
                                      borderColor: UIColor) -> UIImage {
        let sizeToFit = CGSize(width: pixel(num: Double(self.bounds.size.width)), height: Double(self.bounds.size.height))
        let halfBorderWidth = CGFloat(borderWidth / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(sizeToFit, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setLineWidth(borderWidth)
        context!.setStrokeColor(borderColor.cgColor)
        context!.setFillColor(backgroundColor.cgColor)
        
        let width = sizeToFit.width, height = sizeToFit.height
        context?.move(to: CGPoint(x: width - halfBorderWidth, y: radius + halfBorderWidth))// 开始坐标右边开始
        context?.addArc(tangent1End: CGPoint(x:width - halfBorderWidth,y:height - halfBorderWidth) , tangent2End: CGPoint(x:width - radius - halfBorderWidth,y:height - halfBorderWidth), radius: radius)  // 右下角角度
        context?.addArc(tangent1End: CGPoint(x:halfBorderWidth,y:height - halfBorderWidth) , tangent2End: CGPoint(x:halfBorderWidth,y:height - radius - halfBorderWidth), radius: radius)  // 左下角角度
        context?.addArc(tangent1End: CGPoint(x:halfBorderWidth,y:halfBorderWidth) , tangent2End: CGPoint(x:width - halfBorderWidth,y:halfBorderWidth), radius: radius)  // 左上角
        context?.addArc(tangent1End: CGPoint(x:width - halfBorderWidth,y:halfBorderWidth) , tangent2End: CGPoint(x:width - halfBorderWidth,y:radius + halfBorderWidth), radius: radius)  // 右上角
        context?.drawPath(using: .fillStroke)
//        UIGraphicsGetCurrentContext()!.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
//        let out1 = context?.makeImage()
        UIGraphicsEndImageContext()
        return output!
    }
}

public extension UIImage {
    
    func xb_drawRectWithRoundedCorner(radius: CGFloat, _ sizetoFit: CGSize) -> UIImage {
        
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizetoFit)
        
        
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        UIGraphicsGetCurrentContext()!.addPath(UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners,
                                      
                                      cornerRadii: CGSize(width: radius, height: radius)).cgPath)
        
        UIGraphicsGetCurrentContext()?.clip()
        
        
        
        self.draw(in: rect)
        
        UIGraphicsGetCurrentContext()!.drawPath(using: .fillStroke)
        
        let output = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        
        
        return output!
        
    }
    
}

extension UIImageView :CAAnimationDelegate{
    
    /**
     
     / !!!只有当 imageView 不为nil 时，调用此方法才有效果
     
     :param: radius 圆角半径
     
     */

    @objc public override func xb_addCorner(radius: CGFloat) {
        
        self.image = self.image?.xb_drawRectWithRoundedCorner(radius: radius, self.bounds.size)
        
    }
    
}
