//
//  NavgationController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/4.
//

import UIKit

class NavgationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
