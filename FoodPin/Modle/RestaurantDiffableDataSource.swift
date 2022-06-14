//
//  RestaurantDiffableDataSource.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/6/13.
//

import UIKit

enum Section {
    case all
}

class RestaurantDiffableDataSource: UITableViewDiffableDataSource<Section, Restaurant> {
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
