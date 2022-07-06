//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/6/14.
//

import UIKit

class RestaurantDetailViewController: UIViewController {

    var restaurant: Restaurant = Restaurant()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: RestaurantDetailHeaderView!
    @IBOutlet var rateImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.hidesBarsOnSwipe = false
        
        // ch.16=exercise3
        navigationItem.backButtonTitle = ""
        
        tableView.contentInsetAdjustmentBehavior = .never

        tableView.delegate = self
        tableView.dataSource = self
        
        headerView.nameLabel.text = restaurant.name
        headerView.typeLabel.text = restaurant.type
        headerView.headerImageView.image = UIImage(named: restaurant.image)
        
        let heartImage = restaurant.isFavorite ? "heart.fill" : "heart"
        headerView.heartButton.tintColor = restaurant.isFavorite ? .systemYellow : .white
        headerView.heartButton.setImage(UIImage(systemName: heartImage), for: .normal)
        
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        
        case "showMap":
            let destinationController = segue.destination as! MapViewController
            destinationController.resaurant = self.restaurant
             
        case "showRateView":
            let destinationController = segue.destination as! RateViewController
            destinationController.restaurant = self.restaurant
            
        default:
            break
        }
    }
    
    @IBAction func close(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func rateRestaurant(segue: UIStoryboardSegue) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        dismiss(animated: true, completion: {
            
            if let rating = Restaurant.Rating(rawValue: identifier) {
                self.restaurant.rating = rating
                self.rateImageView.image = UIImage(named: rating.image)
            }
            
            let scaleTransform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            self.rateImageView.transform = scaleTransform
            self.rateImageView.alpha = 0
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7, options: [], animations: {
                self.rateImageView.transform = .identity
                self.rateImageView.alpha = 1
            }, completion: nil)
        })
    }
}

extension RestaurantDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantDetailTextCell.self), for: indexPath) as! RestaurantDetailTextCell
            
            cell.descriptionLabel.text = restaurant.description
            
            return cell
        
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TwoColumnCell.self), for: indexPath) as! TwoColumnCell
            
            cell.column1TitleLabel.text = "Address"
            cell.column1TextLabel.text = restaurant.location
            cell.column2TitleLabel.text = "Phone"
            cell.column2TextLabel.text = restaurant.phone
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantDetailMapCell.self), for: indexPath) as! RestaurantDetailMapCell
            cell.configure(location: restaurant.location)
            
            return cell
            
        default:
            fatalError("Fail to instantiate the table view cell for detail view controller")
        }
    }
}
