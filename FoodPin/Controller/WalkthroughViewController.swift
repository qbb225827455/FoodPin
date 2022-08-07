//
//  WalkthroughViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/12.
//

import UIKit

func createQucikAction() {
    
    // 加入快速動作
    if let bundleID = Bundle.main.bundleIdentifier {
        
        let shortcutItem1 = UIApplicationShortcutItem(type: "\(bundleID).openFavorites", localizedTitle: String(localized: "Show Favorites"), localizedSubtitle: nil, icon: UIApplicationShortcutIcon(systemImageName: "tag"), userInfo: nil)
        let shortcutItem2 = UIApplicationShortcutItem(type: "\(bundleID).openDiscover", localizedTitle: String(localized: "Discover Restaurants"), localizedSubtitle: nil, icon: UIApplicationShortcutIcon(systemImageName: "eyes"), userInfo: nil)
        let shortcutItem3 = UIApplicationShortcutItem(type: "\(bundleID).newRestaurant", localizedTitle: String(localized: "New Restaurant"), localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
        let shortcutItem4 = UIApplicationShortcutItem(type: "\(bundleID).openAbout", localizedTitle: String(localized: "About"), localizedSubtitle: nil, icon: UIApplicationShortcutIcon(systemImageName: "info.circle"), userInfo: nil)
        
        UIApplication.shared.shortcutItems = [shortcutItem1, shortcutItem2, shortcutItem3, shortcutItem4]
    }
}

class WalkthroughViewController: UIViewController {

    // MARK: - Properties
    
    var walkthroughPageViewController: WalkthroughPageViewController?
    
    // MARK: - IBOutlet
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var nextBtn: UIButton! {
        didSet {
            nextBtn.layer.cornerRadius = 25
            nextBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var skipBtn: UIButton!
    
    // MARK: - IBAction
    
    @IBAction func nextBtnTapped(sender: UIButton) {
        
        if let index = walkthroughPageViewController?.currentIndex {
            
            switch index {
            case 0...1:
                walkthroughPageViewController?.forwardPage()
                
            case 2:
                UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
                createQucikAction()
                addTestData()
                dismiss(animated: true, completion: nil)
                
            default:
                break
            }
        }
        
        updateUI()
    }
    
    @IBAction func skipBtnTapped(sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
        createQucikAction()
        addTestData()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkthroughPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
    
    // MARK: - Function
    
    func updateUI() {

        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                nextBtn.setTitle(String(localized: "NEXT"), for: .normal)
                skipBtn.isHidden = false
                
            case 2:
                nextBtn.setTitle(String(localized: "GET STARTED"), for: .normal)
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
