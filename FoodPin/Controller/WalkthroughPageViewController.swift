//
//  WalkthroughPageViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/12.
//

import UIKit

protocol WalkthroughPageViewControllerDelegate: AnyObject {
    
    func didUpdatePageIndex(currentIndex: Int)
}

class WalkthroughPageViewController: UIPageViewController {

    // MARK : - Properties
    
    weak var walkthroughDelegate: WalkthroughPageViewControllerDelegate?
    
    var pageImages = ["onboarding-1", "onboarding-2", "onboarding-3"]
    
    var pageHeadings = ["CREATE YOUR OWN FOOD GUIDE",
                        "SHOW YOU THE LOCATION",
                        "DISCOVER GREAT RESTAURANTS"]
    
    var pageSubHeadings = ["Pin your favorite restaurants and create your own food guide",
                           "Search and locate your favourite restaurant on Maps",
                           "Find restaurants shared by your friends and other foodies"]
    
    var currentIndex = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        // create first view
        if let startViewController = contentViewController(at: 0) {
            setViewControllers([startViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // MARK: - Function
    
    func forwardPage() {
        
        currentIndex += 1
        if let nextViewController = contentViewController(at: currentIndex) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension WalkthroughPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = (viewController as! WalkthroughContentViewController).pageIndex - 1
        
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = (viewController as! WalkthroughContentViewController).pageIndex + 1
        
        return contentViewController(at: index)
    }
    
    // MARK: Function
    
    /// 設定導覽頁面中各頁的顯示內容
    /// - Parameter index: 導覽頁面的目前頁數
    /// - Returns: 顯示內容
    func contentViewController(at index: Int) -> WalkthroughContentViewController? {
        
        if index < 0 || index >= pageHeadings.count {
            return nil
        }
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController {
            
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.headingText = pageHeadings[index]
            pageContentViewController.subheadingText = pageSubHeadings[index]
            pageContentViewController.pageIndex = index
            
            return pageContentViewController
        }
        
        return nil
    }
}

// MARK: - UIPageViewControllerDelegate

extension WalkthroughPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            
            if let contentViewController = pageViewController.viewControllers?.first as? WalkthroughContentViewController {
                
                currentIndex = contentViewController.pageIndex
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: contentViewController.pageIndex)
            }
        }
    }
}
