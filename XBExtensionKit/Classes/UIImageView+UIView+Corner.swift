//
//  UIImageView+Corner.swift
//  TopNews
//  给UIView和UIImageView加圆角的扩展，不会出现离屏渲染
//  Created by xb on 2017/8/14.
//  Copyright © 2017年 xb. All rights reserved.
//

import UIKit
import SDWebImage
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
    
    //网络加载图片，带有圆角
    func sd_xb_loadImage(with url:URL?, placeholderImage : UIImage? = nil, options: SDWebImageOptions = [], progress:SDWebImageDownloaderProgressBlock? = nil, completed: SDExternalCompletionBlock? = nil) {
        if url == nil {
            self.image = placeholderImage
            return
        }
        var startTime: TimeInterval = Date().timeIntervalSince1970 * 1000
        self.sd_setImage(with: url, placeholderImage: placeholderImage, options: (options.isEmpty ? .lowPriority : options), progress: progress, completed: { (image, error, cacheType, url) in
            completed?(image, error, cacheType, url)
            if cacheType == .none { // 只有当缓存中没有图片，也就是首次加载时才实现CATransition动画
                let transition:CATransition = CATransition()
                transition.type = CATransitionType.fade // 褪色效果，渐进效果的基础
                transition.duration = 0.2
                transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut) // 先慢后快再慢
                transition.delegate = self
                self.layer.add(transition, forKey: "newVoteTimeline") // 在layer中加入动画，并约定好该动画的key
                StatisticsLogManager.shared.log(event: "image", parameters: ["network": Utils.getNetworkType(), "success": error != nil, "url": url?.absoluteString ?? "", "used_ms": (Date().timeIntervalSince1970 * 1000 - startTime)], module: .client_perf)
            }
        })
        
//        if radius != 0 {
//            let key = SDWebImageManager.shared().cacheKey(for: url)
//            let keySelf = (key ?? "") + "\(radius)"
//            let cacheImg = SDWebImageManager.shared().imageCache?.imageFromCache(forKey: keySelf)
//            if cacheImg != nil {
//                self.image = cacheImg
//            } else {
//                self.sd_setImage(with: url, placeholderImage: placeholderImage, options: (options.isEmpty ? .lowPriority : options), completed: { (image, error, cacheType, url) in
//                    if error == nil {
//                        let radiusImg = image?.xb_drawRectWithRoundedCorner(radius: radius, self.frame.size)
//                        self.image = radiusImg
//                        SDWebImageManager.shared().imageCache?.removeImage(forKey: key, withCompletion: nil)
//                        //保存当前圆角大小的图片
//                        SDWebImageManager.shared().imageCache?.store(radiusImg, forKey: keySelf, completion: nil)
//
//
//                        if cacheType == .none { // 只有当缓存中没有图片，也就是首次加载时才实现CATransition动画
//                            let transition:CATransition = CATransition()
//                            transition.type = CATransitionType.fade // 褪色效果，渐进效果的基础
//                            transition.duration = 0.4
//                            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut) // 先慢后快再慢
//                            transition.delegate = self
//                            self.layer.add(transition, forKey: "newVoteTimeline") // 在layer中加入动画，并约定好该动画的key
//                        }
//                    }
//                })
//            }
//        } else {
//            self.sd_setImage(with: url, placeholderImage: placeholderImage, options: (options.isEmpty ? .lowPriority : options), completed: { (image, error, cacheType, url) in
//
//                if cacheType == .none { // 只有当缓存中没有图片，也就是首次加载时才实现CATransition动画
//                    let transition:CATransition = CATransition()
//                    transition.type = CATransitionType.fade // 褪色效果，渐进效果的基础
//                    transition.duration = 0.4
//                    transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut) // 先慢后快再慢
//                    transition.delegate = self
//                    self.layer.add(transition, forKey: "newVoteTimeline") // 在layer中加入动画，并约定好该动画的key
//                }
//            })
//        }
    }
//    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        if flag {
//            self.layer.removeAnimation(forKey: "newVoteTimeline") // 当newVoteTimeline动画已经完成，将其从layer中移除，避免复用中的产生反复「渐变」效果
//        }
//    }
}
