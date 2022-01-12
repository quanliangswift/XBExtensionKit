//
//  DoubleExtension.swift
//  TopNews
//
//  Created by leiyuncun on 2019/1/11.
//  Copyright © 2019 xb. All rights reserved.
//

import Foundation


extension Double {
    
    // 将时间戳改为 Date 类型
    func toDate() -> Date {
        return Date(timeIntervalSince1970: self)
    }
    
}
