//
//  RestaurantTableViewCell.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/6/2.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tintColor = .systemYellow
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    
    @IBOutlet var thumbnaiImageView: UIImageView! {
        didSet {
            thumbnaiImageView.layer.cornerRadius = 20
            thumbnaiImageView.clipsToBounds = true
        }
    }
    @IBOutlet var favoriteImage: UIImageView!
    
}
