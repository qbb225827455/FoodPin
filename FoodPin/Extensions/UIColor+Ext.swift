//
//  UIColor+Ext.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/4.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        
        let redVal = CGFloat(red) / 255
        let greenVal = CGFloat(green) / 255
        let blueVal = CGFloat(blue) / 255
        
        self.init(red: redVal, green: greenVal, blue: blueVal, alpha: 1)
    }
}
