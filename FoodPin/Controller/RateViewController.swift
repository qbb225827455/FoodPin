//
//  RateViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/6.
//

import UIKit

class RateViewController: UIViewController {

    var restaurant = Restaurant()
    
    @IBOutlet var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        backgroundImageView.image = UIImage(named: restaurant.image)
        
        //
    }
}
