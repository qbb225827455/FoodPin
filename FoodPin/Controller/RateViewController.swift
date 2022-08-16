//
//  RateViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/6.
//

import UIKit

class RateViewController: UIViewController {

    // MARK: - Properties
    
    var restaurant = Restaurant()
    var blurEffectView: UIVisualEffectView?
    
    // MARK: - IBOutlet
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var rateBtn: [UIButton]!
    @IBOutlet var closeBtn: UIButton!
    
    // MARK: - Livecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.image = UIImage(data: restaurant.image)
        
        // 背景模糊
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView!)
        
        // rateBtn tranform
        let moveRightTransform = CGAffineTransform.init(translationX: 600, y: 0)
        let scaleUpTransform = CGAffineTransform.init(scaleX: 5, y: 5)
        let moveScaleTransform = scaleUpTransform.concatenating(moveRightTransform)
        
        for rateBtn in rateBtn {
            rateBtn.alpha = 0
            rateBtn.transform = moveScaleTransform
        }
        
        // closeBtn transform
        let moveTopTransform = CGAffineTransform.init(translationX: 0, y: -600)
    
        closeBtn.transform = moveTopTransform
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
        var delay = 0.1
        
        for rateBtn in rateBtn {
            UIView.animate(withDuration: 0.4, delay: delay, options: [], animations: {
                rateBtn.alpha = 1.0
                rateBtn.transform = .identity
            }, completion: nil)
            delay = delay + 0.1
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [], animations: {
            self.closeBtn.transform = .identity
        }, completion: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        blurEffectView?.frame = view.bounds
    }
}
