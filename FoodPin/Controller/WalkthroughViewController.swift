//
//  WalkthroughViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/12.
//

import UIKit

class WalkthroughViewController: UIViewController {

    var walkthroughPageViewController: WalkthroughPageViewController?
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var nextBtn: UIButton! {
        didSet {
            nextBtn.layer.cornerRadius = 25
            nextBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var skipBtn: UIButton!
    
    @IBAction func nextBtnTapped(sender: UIButton) {
        
        if let index = walkthroughPageViewController?.currentIndex {
            
            switch index {
            case 0...1:
                walkthroughPageViewController?.forwardPage()
                
            case 2:
                UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
                dismiss(animated: true, completion: nil)
                
            default:
                break
            }
        }
        
        updateUI()
    }
    
    @IBAction func skipBtnTapped(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkthroughPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
    
    func updateUI() {

        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                nextBtn.setTitle("NEXT", for: .normal)
                skipBtn.isHidden = false
                
            case 2:
                nextBtn.setTitle("GET STARTED", for: .normal)
                skipBtn.isHidden = true
                
            default:
                break
            }
            
            pageControl.currentPage = index
        }
        
    }
}

extension WalkthroughViewController: WalkthroughPageViewControllerDelegate {
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
}
