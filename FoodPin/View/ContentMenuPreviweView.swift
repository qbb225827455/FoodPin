//
//  ContentMenuPreviweView.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/8/9.
//

import UIKit

class ContentMenuPreviweView: UIView {

    @IBOutlet var restaurantImageView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel! {
        didSet {
            
            nameLabel.numberOfLines = 0
            nameLabel.adjustsFontForContentSizeCategory = true
            
            if let customFont = UIFont(name: "Nunito-Bold", size: 40.0) {
                nameLabel.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: customFont)
            }
        }
    }
    
    @IBOutlet var typeLabel: UILabel! {
        didSet {
            
            typeLabel.numberOfLines = 0
            typeLabel.adjustsFontForContentSizeCategory = true
            
            if let customFont = UIFont(name: "Nunito-Regular", size: 20.0) {
                typeLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont)
            }
        }
    }
}
