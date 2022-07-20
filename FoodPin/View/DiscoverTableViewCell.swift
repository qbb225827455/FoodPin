//
//  DiscoverTableViewCell.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/21.
//

import UIKit

class DiscoverTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet var thumbnailImageView: UIImageView! {
        didSet {
            thumbnailImageView.layer.cornerRadius = 20
            thumbnailImageView.clipsToBounds = true
            thumbnailImageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet var nameLabel: UILabel! {
        didSet {
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var locationLabel: UILabel! {
        didSet {
            locationLabel.adjustsFontSizeToFitWidth = true
            locationLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var typeLabel: UILabel! {
        didSet {
            typeLabel.adjustsFontSizeToFitWidth = true
            typeLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.adjustsFontSizeToFitWidth = true
            descriptionLabel.numberOfLines = 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
