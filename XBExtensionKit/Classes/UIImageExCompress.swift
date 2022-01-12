//
//  UIImageExtension.swift
//  Ahihi
//
//  Created by leiyuncun on 2018/9/21.
//  Copyright © 2018年 xb. All rights reserved.
//

import Foundation

public extension UIImage {
    
    /// 将图片剪裁成圆形
    ///
    /// - Parameter image: 指定的图片
    /// - Returns: 圆形图片
    class func imagewithImage(image:UIImage) -> UIImage{
        let width = image.size.width
        let height = image.size.height
        let redius = ((width <= height) ? width : height)/2;
        let rect = CGRect(x: width/2-redius,y: height/2-redius,width: redius*2,height: redius*2);
        let sourceImageRef = image.cgImage
        let newImageRef =  sourceImageRef?.cropping(to: rect)
        let newImage = UIImage(cgImage: newImageRef!)
        UIGraphicsBeginImageContextWithOptions(CGSize(width:newImage.size.width,height: newImage.size.height), false, 0);
        let path = UIBezierPath(arcCenter: CGPoint(x: newImage.size.width / 2, y: newImage.size.height / 2), radius: redius, startAngle: 0, endAngle:CGFloat(Double.pi * 2.0), clockwise: false)
        path.addClip()
        newImage.draw(at: CGPoint.zero)
        let imageCut = UIGraphicsGetImageFromCurrentImageContext()
        return imageCut!
    }
    
    
    /// 根据 size 重设图片大小
    ///
    /// - Parameter reSize: 重新设定的 size
    /// - Returns: 新图片
    func reSizeImage(reSize:CGSize) -> UIImage {
        //UIGraphicsBeginImageContext(reSize)
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale)
        self.draw(in: CGRect(x: 0,y: 0,width: reSize.width,height: reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    
    
    /// 等比率缩放
    ///
    /// - Parameter scaleSize: 比率
    /// - Returns: 新图片
    func scaleImage(scaleSize:CGFloat) -> UIImage {
        let reSize = CGSize(width:self.size.width * scaleSize,height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
    
    
    /// 压缩上传图片到指定字节
    ///
    /// - Parameters:
    ///   - image:  压缩的图片
    ///   - maxLength: 压缩后最大字节大小
    /// - Returns: 压缩后图片的二进制
    func compressImage(image: UIImage, maxLength: Int) -> NSData? {
        let newSize = self.scaleImage(image: image, imageLength: 800)
        let newImage = self.resizeImage(image: image, newSize: newSize)
        var compress:CGFloat = 0.9
        var data = newImage.jpegData(compressionQuality: compress)!
        while (data.count) > maxLength && compress > 0.01 {
            compress -= 0.02
            data = newImage.jpegData(compressionQuality: compress)!
        }
        return data as NSData
    }
    

    
    /// 通过指定图片最长边，获得等比例的图片size
    ///
    /// - Parameters:
    ///   - image: 原始图片
    ///   - imageLength: 图片允许的最长宽度（高度）
    /// - Returns: 获得等比例的size
    func scaleImage(image: UIImage, imageLength: CGFloat) -> CGSize {
        var newWidth:CGFloat = 0.0
        var newHeight:CGFloat = 0.0
        let width = image.size.width
        let height = image.size.height
        if (width > imageLength || height > imageLength){
            if (width > height) {
                newWidth = imageLength;
                newHeight = newWidth * height / width;
            }else if(height > width){
                newHeight = imageLength;
                newWidth = newHeight * width / height;
            }else{
                newWidth = imageLength;
                newHeight = imageLength;
            }
        }
        return CGSize(width: newWidth, height: newHeight)
    }
    
    
    /// 获得指定size的图片
    ///
    /// - Parameters:
    ///   - image: 原始图片
    ///   - newSize: 指定的size
    /// - Returns: 调整后的图片
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
}

public enum WechatCompressType {
    case session
    case timeline
}

extension UIImage {

    /**
     wechat image compress

     - parameter type: session image boundary is 800, timeline is 1280

     - returns: thumb image
     */
    public func wxCompress(type: WechatCompressType = .timeline, size: Int = 300) -> (UIImage, Data) {
        let sizeTemp = self.wxImageSize(type: type)
        let reImage = resizedImage(size: sizeTemp)

        let firstCompressData = self.jpegData(compressionQuality: 0.7)!
        if firstCompressData.count < size * 1024 {
            return (UIImage.init(data: firstCompressData)!, firstCompressData)
        } else {
            var data = firstCompressData
            var compress: CGFloat = 0.4
            while data.count > size * 1024 {
                data = self.jpegData(compressionQuality: compress)!
                compress -= 0.1
                if compress > 0.1 {
                    compress -= 0.1
                } else {
                    break
                }
            }
            return (UIImage.init(data: data)!, data)
        }
    }

    /**
     get wechat compress image size

     - parameter type: session  / timeline

     - returns: size
     */
    private func wxImageSize(type: WechatCompressType) -> CGSize {
        var width = self.size.width
        var height = self.size.height

        var boundary: CGFloat = 1280

        // width, height <= 1280, Size remains the same
        guard width > boundary || height > boundary else {
            return CGSize(width: width, height: height)
        }

        // aspect ratio
        let s = max(width, height) / min(width, height)
        if s <= 2 {
            // Set the larger value to the boundary, the smaller the value of the compression
            let x = max(width, height) / boundary
            if width > height {
                width = boundary
                height = height / x
            } else {
                height = boundary
                width = width / x
            }
        } else {
            // width, height > 1280
            if min(width, height) >= boundary {
                boundary = type == .session ? 800 : 1280
                // Set the smaller value to the boundary, and the larger value is compressed
                let x = min(width, height) / boundary
                if width < height {
                    width = boundary
                    height = height / x
                } else {
                    height = boundary
                    width = width / x
                }
            }
        }
        return CGSize(width: width, height: height)
    }

    /**
     Zoom the picture to the specified size

     - parameter newSize: image size

     - returns: new image
     */
    private func resizedImage(size: CGSize) -> UIImage {
        let newRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        var newImage: UIImage!
        UIGraphicsBeginImageContext(newRect.size)
        newImage = UIImage(cgImage: self.cgImage!, scale: 1, orientation: self.imageOrientation)
        newImage.draw(in: newRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

}


extension UIImage {
    /// 加水印
    public func addWatermark(_ watermark: UIImage, rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        watermark.draw(in: rect, blendMode: CGBlendMode.normal, alpha: 1.0)
        
        let resultImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resultImage
    }
}

