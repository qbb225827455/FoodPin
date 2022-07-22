//
//  AboutViewDataSource.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/22.
//

import UIKit

enum AboutSection {
    case feedback
    case followus
}

struct LinkItem: Hashable {
    var text: String
    var link: String
    var image: String
}

class AboutViewDataSource: UITableViewDiffableDataSource<AboutSection, LinkItem> {
    
}
