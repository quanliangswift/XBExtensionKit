//
//  UIViewSnapshot.swift
//  TopNews
//
//  Created by leiyuncun on 2018/12/19.
//  Copyright © 2018 xb. All rights reserved.
//

import Foundation

//  refer to: https://www.jianshu.com/p/f80e2b57f304
public extension UIView {
    /// 截取指定 view 转为 image
    func snapshotImage() -> UIImage {
        // 系统自带的 snapshotView 方法返回的 UIView？ 不能直接存储到相册中
        // 参数：截屏区域, 是否透明,清晰度
        UIGraphicsBeginImageContextWithOptions(self.frame.size, true, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return image;
    }
}


public extension UIScrollView {
    // refer: https://github.com/Teacher-Fu/FQScreenshot
    func snapshot(finishBlocck: ((UIImage) -> Void )?) {
        var shotImage:UIImage?
        //保存offset
        let oldContent = self.contentOffset
        //保存frame
        let oldFrame = self.frame
        
        if self.contentSize.height > self.frame.height{
            self.contentOffset = CGPoint(x: 0, y:self.contentSize.height - self.frame.height)
        }
        self.layer.frame = CGRect(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height)
        //延时操作
        Thread.sleep(forTimeInterval: 0.3)
        self.contentOffset = CGPoint.zero
        autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
            let currentContent = UIGraphicsGetCurrentContext()
            self.layer.render(in: currentContent!)
            shotImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        self.frame = oldFrame
        self.contentOffset = oldContent
        if shotImage != nil && finishBlocck != nil{
            finishBlocck?(shotImage!)
        }
    }
    
    /*
     *  shotView:需要截取的view
     */
    static func screenShotWithShotView(_ shotView:UIView) -> UIImage{
        return self.screenShotWithShotView(shotView, shotSize: CGSize.zero)
    }
    /*
     *  shotView:需要截取的view
     *  shotSize:需要截取的size
     */
    static func screenShotWithShotView(_ shotView:UIView,shotSize:CGSize) -> UIImage{
        var shotImage:UIImage?
        var newShotSize = shotSize
        autoreleasepool{
            if newShotSize.height == 0 || newShotSize.width == 0{
                newShotSize = shotView.bounds.size
            }
            //创建
            UIGraphicsBeginImageContextWithOptions(newShotSize, false, UIScreen.main.scale)
            let currentContext = UIGraphicsGetCurrentContext()
            shotView.layer.render(in: currentContext!)
            //获取图片
            shotImage = UIGraphicsGetImageFromCurrentImageContext()
            //关闭
            UIGraphicsEndImageContext()
        }
        return shotImage!
    }
}

public extension UIImage {
    // 将两张图片拼接成一张图片，由此可以增加多张图拼接，包括上下拼接，左右拼接
    func combin(_ image:UIImage) -> UIImage {
        let width = max(self.size.width, image.size.width)
        let height = self.size.height + image.size.height
        let offScreenSize = CGSize.init(width: width, height: height)
        
        UIGraphicsBeginImageContext(offScreenSize);
        
        let rect = CGRect.init(x:0, y:0, width:width, height:self.size.height)
        self.draw(in: rect)
        
        let rect2 = CGRect.init(x:0, y:self.size.height, width:width, height:image.size.height)
        self.draw(in: rect2)
        
        let combinImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext();
        
        return combinImage;
    }
}
