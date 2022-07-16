//
//  WalkthroughContentViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/12.
//

import UIKit

class WalkthroughContentViewController: UIViewController {

    // MARK: Properties
    
    var pageIndex = 0
    var headingText = ""
    var subheadingText = ""
    var imageFile = ""
    
    // MARK: IBOutlet
    
    @IBOutlet var contentImageView: UIImageView!
    
    @IBOutlet var headingLabel: UILabel! {
        didSet {
            headingLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var subheadingLabel: UILabel! {
        didSet {
            subheadingLabel.numberOfLines = 0
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentImageView.image = UIImage(named: imageFile)
        headingLabel.text = headingText
        subheadingLabel.text = subheadingText
    }

}
