//
//  String+md5.swift
//  TopNews
//
//  Created by 叶进兵 on 2017/2/22.
//  Copyright © 2017年 xb. All rights reserved.
//

import Foundation
import CryptoSwift
import CommonCrypto

public extension String {
    func md5() -> String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate()

        return String(format: hash as String)
    }
    
    func base64EncodeString() -> String? {
        let data = self.data(using: .utf8)
        return data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
    
    func base64Decoded() -> String? {
        if let _ = self.range(of: ":")?.lowerBound {
            return self
        }
        let base64String = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        let padding = base64String.count + (base64String.count % 4 != 0 ? (4 - base64String.count % 4) : 0)
        if let decodedData = Data(base64Encoded: base64String.padding(toLength: padding, withPad: "=", startingAt: 0), options: NSData.Base64DecodingOptions(rawValue: 0)), let decodedString = NSString(data: decodedData, encoding: String.Encoding.utf8.rawValue) {
            return decodedString as String
        }
        return nil
    }
    
    
    func base64StringToUIImage() -> UIImage? {
        var str = self
        // 1、判断用户传过来的base64的字符串是否是以data开口的，如果是以data开头的，那么就获取字符串中的base代码，然后在转换，如果不是以data开头的，那么就直接转换
        if str.hasPrefix("data:image") {
            guard let newBase64String = str.components(separatedBy: ",").last else {
                return nil
            }
            str = newBase64String
        }
        // 2、将处理好的base64String代码转换成NSData
        guard let imgNSData = Data(base64Encoded: str, options: []) else {
            return nil
        }
        // 3、将NSData的图片，转换成UIImage
        guard let codeImage = UIImage(data: imgNSData) else {
            return nil
        }
        return codeImage
    }
}
public extension UIImage {
    ///传入图片image回传对应的base64字符串,默认不带有data标识,
    func imageToBase64String(headerSign:Bool = false)->String?{

        ///根据图片得到对应的二进制编码
        
        guard let imageData = self.pngData() else {
            return nil
        }
        ///根据二进制编码得到对应的base64字符串
        
        var base64String = imageData.base64EncodedString(options: [])
        ///判断是否带有头部base64标识信息
        if headerSign, !base64String.hasPrefix("data:image") {
            ///根据格式拼接数据头 添加header信息，扩展名信息
            base64String = "data:image/png;base64," + base64String
        }
        return base64String
    }
}
public extension String {
    /// 从 0 开始到 toIndex
    func xb_subString(to index: Int) -> String {
        return String(self[..<self.index(self.startIndex, offsetBy: index)])
    }
    
    /// 从 fromIndex 到 end
    func xb_subString(from index: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: index)...])
    }
    
    /// 最后几个字符串
    func xb_subString(last: Int) -> String {
        guard self.count >= last else {
            fatalError("last must smaller than count")
        }
        let lastIndex = self.index(self.endIndex, offsetBy: -last)
        return String(self[lastIndex...])
    }
    
    /// 从 fromIndex 到 toIndex
    func xb_subString(from fromIndex: Int, to toIndex: Int) -> String {
        guard fromIndex < toIndex else {
            fatalError("fromIndex must samller than toIndex")
        }
        return String(self[self.index(self.startIndex, offsetBy: fromIndex)..<self.index(self.startIndex, offsetBy: toIndex)])
    }
    
    /// 从距离 0 start 个单位到 距离最后一个 end 个单位的子串
    func xb_subString(start: Int, end: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(self.endIndex, offsetBy: -end)
        
        guard startIndex < endIndex else {
            fatalError("startIndex must samller than endIndex")
        }
        
        //        let range = Range(startIndex..<endIndex)
        let range = startIndex..<endIndex
        return String(self[range])
    }
    
}


public extension String {
    
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    func ranges(of searchString: String, options mask: NSString.CompareOptions = [], locale: Locale? = nil) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        while let range = range(of: searchString, options: mask, range: (ranges.last?.upperBound ?? startIndex)..<endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
    
    func nsRanges(of searchString: String, options mask: NSString.CompareOptions = [], locale: Locale? = nil) -> [NSRange] {
        let ranges = self.ranges(of: searchString, options: mask, locale: locale)
        return ranges.map { nsRange(from: $0) }
    }
    
    /// 根据字符串 获取 Label 控件的高度
    func getLabelStringHeightFrom(labelWidth: CGFloat, font: UIFont) -> CGFloat {
        let topOffset = CGFloat(0)
        let bottomOffset = CGFloat(0)
        let textContentWidth = labelWidth
        let normalText: NSString = self as NSString
        let size = CGSize(width: textContentWidth, height: 1000)
        let attributes = [NSAttributedString.Key.font: font]
        let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context:nil).size
        return  CGFloat(ceilf(Float(stringSize.height)))+topOffset+bottomOffset
    }
    
    func boundingRect(with constrainedSize: CGSize, font: UIFont, lineSpacing: CGFloat? = nil) -> CGSize {
        let attritube = NSMutableAttributedString(string: self)
        let range = NSRange(location: 0, length: attritube.length)
        attritube.addAttributes([NSAttributedString.Key.font: font], range: range)
        if lineSpacing != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing!
            attritube.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        }
        
        let rect = attritube.boundingRect(with: constrainedSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        var size = rect.size
        
        if let currentLineSpacing = lineSpacing {
            // 文本的高度减去字体高度小于等于行间距，判断为当前只有1行
            let spacing = size.height - font.lineHeight
            if spacing <= currentLineSpacing && spacing > 0 {
                size = CGSize(width: size.width, height: font.lineHeight)
            }
        }
        
        return size
    }
    
    func boundingRect(with constrainedSize: CGSize, font: UIFont, lineSpacing: CGFloat? = nil, lines: Int) -> CGSize {
        if lines < 0 {
            return .zero
        }
        
        let size = boundingRect(with: constrainedSize, font: font, lineSpacing: lineSpacing)
        if lines == 0 {
            return size
        }

        let currentLineSpacing = (lineSpacing == nil) ? (font.lineHeight - font.pointSize) : lineSpacing!
        let maximumHeight = font.lineHeight*CGFloat(lines) + currentLineSpacing*CGFloat(lines - 1)
        if size.height >= maximumHeight {
            return CGSize(width: size.width, height: maximumHeight)
        }
        
        return size
    }
}

public extension String {
    /// 正则匹配
    ///
    /// - Parameters:
    ///   - regex: 匹配规则
    /// - Returns: 返回结果
    func matchRegularExpression(regex: String) -> [String] {
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
            let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            
            var result: [String] = []
            for item in matches {
                let string = (self as NSString).substring(with: item.range)
                result.append(string)
            }
            return result
        }
        catch {
            return []
        }
    }
}



