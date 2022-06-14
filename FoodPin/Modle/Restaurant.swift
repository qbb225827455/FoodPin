//
//  Restaurant.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/6/13.
//

import Foundation

struct Restaurant: Hashable {
    
    var name: String = ""
    var type: String = ""
    var location: String = ""
    var phone: String = ""
    var description: String = ""
    var image: String = ""
    var isFavorite: Bool = false
}
