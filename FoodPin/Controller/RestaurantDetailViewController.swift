//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/6/14.
//

import UIKit

class RestaurantDetailViewController: UIViewController {

    var restaurantImageName = ""
    var restaurantName = ""
    var restaurantType = ""
    var restaurantLocation = ""

    @IBOutlet var restaurantImageView: UIImageView!
    @IBOutlet var restaurantNameLabel: UILabel!
    @IBOutlet var restaurantTypeLabel: UILabel!
    @IBOutlet var restaurantLocationLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        
        // Do any additional setup after loading the view.
        restaurantImageView.image = UIImage(named: restaurantImageName)
        restaurantNameLabel.text = restaurantName
        restaurantTypeLabel.text = restaurantType
        restaurantLocationLabel.text = restaurantLocation
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
