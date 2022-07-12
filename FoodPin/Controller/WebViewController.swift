//
//  WebViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/13.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var targetURL = ""
    
    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: targetURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
