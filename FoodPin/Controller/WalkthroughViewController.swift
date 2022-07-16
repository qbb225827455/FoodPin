//
//  WalkthroughViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/12.
//

import UIKit

class WalkthroughViewController: UIViewController {

    // MARK: Properties
    
    var walkthroughPageViewController: WalkthroughPageViewController?
    
    // MARK: IBOutlet
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var nextBtn: UIButton! {
        didSet {
            nextBtn.layer.cornerRadius = 25
            nextBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var skipBtn: UIButton!
    
    // MARK: IBAction
    
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
        UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkthroughPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
    
    // MARK: Function
    
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

// MARK: - WalkthroughPageViewControllerDelegate

extension WalkthroughViewController: WalkthroughPageViewControllerDelegate {
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
}
