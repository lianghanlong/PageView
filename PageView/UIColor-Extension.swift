//
//  UIColor-Extension.swift
//  show
//
//  Created by hanlong_liang on 2018/3/7.
//  Copyright © 2018年 kolamama. All rights reserved.
//

import UIKit
// swift 类方法用的比较少，有参数时不建议用类方法 ,可以用构造方法
extension UIColor {
    // 在extension中给系统的类扩充构造函数，只能扩充 “便利构造函数”
    // 两个特点 1.convenience 2.self.init
    // swift 中 alpha:CGFloat = 1.0，会默认生产两个函数，一个是有alpha，一个是没有
    convenience init(r:CGFloat,g:CGFloat,b:CGFloat,alpha:CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    
    convenience init?(hex: String,alpha:CGFloat = 1) {
        
        // 1.判断 输入的字符串少于6位 则直接返回空对象，但是要先定义为init? 可选
        if hex.count < 6 {
            return nil
        }
        
        // 2.把输入的字符串转为大写
        var tempHex: String = hex.uppercased()
        
        // 3.去掉prex : 0x ## #
        if hex.hasPrefix("0x") || hex.hasPrefix("##") {
            tempHex = (tempHex as NSString).substring(from: 2)
        }
        if hex.hasPrefix("#") {
            tempHex = (tempHex as NSString).substring(from: 1)
        }
        
        // 4.截取 r g b分量
        var range = NSRange(location: 0, length: 2)
        let rHex = (tempHex as NSString).substring(with: range)
        range.location = 2
        let gHex = (tempHex as NSString).substring(with: range)
        range.location = 4
        let bHex = (tempHex as NSString).substring(with: range)
        
        // 5.十六进制转换成十进制
        var r:UInt32 = 0,g:UInt32 = 0,b:UInt32 = 0
        
        Scanner(string: rHex).scanHexInt32(&r)
        Scanner(string: gHex).scanHexInt32(&g)
        Scanner(string: bHex).scanHexInt32(&b)
        
        self.init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: alpha)
    }
    
    class func randomColor() -> UIColor {
        return UIColor(r: CGFloat(arc4random_uniform(256)), g: CGFloat(arc4random_uniform(256)), b: CGFloat(arc4random_uniform(256)))
    }
    
}
















