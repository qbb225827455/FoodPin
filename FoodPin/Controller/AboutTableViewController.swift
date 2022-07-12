//
//  AboutTableViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/13.
//

import UIKit
import SafariServices

class AboutTableViewController: UITableViewController {
    
    enum Section {
        case feedback
        case followus
    }
    
    struct LinkItem: Hashable {
        var text: String
        var link: String
        var image: String
    }
    
    var sectionContent = [ [LinkItem(text: "Rate us on App Store", link: "https://www.apple.com/ios/app-store/", image: "store"),
                            LinkItem(text: "Tell us your feedback", link: "http://www.appcoda.com/contact", image: "chat")],
                           
                           [LinkItem(text: "Twitter", link: "https://twitter.com/", image: "twitter"),
                            LinkItem(text: "Facebook", link: "https://facebook.com/", image: "facebook"),
                            LinkItem(text: "Instagram", link: "https://www.instagram.com/", image: "instagram")]
                            ]

    lazy var dataSource = configureDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let appearence = navigationController?.navigationBar.standardAppearance {
            appearence.configureWithTransparentBackground()
            
            if let customFont = UIFont(name: "Nunito-Bold", size: 45.0) {
                appearence.titleTextAttributes = [.foregroundColor: UIColor(named: "NavBarTitle")!]
                appearence.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavBarTitle")!, .font: customFont]
            }
            
            navigationController?.navigationBar.standardAppearance = appearence
            navigationController?.navigationBar.compactAppearance = appearence
            navigationController?.navigationBar.scrollEdgeAppearance = appearence
        }
        
        tableView.dataSource = dataSource
        updateSnapshot()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        // get selected row url
//        guard let linkItem = self.dataSource.itemIdentifier(for: indexPath) else {
//            return
//        }
//
//        if let url = URL(string: linkItem.link) {
//            UIApplication.shared.open(url)
//        }
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "showWebView", sender: self)
            
        case 1:
            openWithSafariViewController(indexPath: indexPath)
        
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Diffable Data Source
    
    func configureDataSource() -> UITableViewDiffableDataSource<Section, LinkItem> {
        
        let cellIdentifier = "aboutcell"
        
        let dataSource = UITableViewDiffableDataSource<Section, LinkItem>(
            
            tableView: tableView,
            cellProvider: {tableView, indexPath, linkItem in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
                cell.textLabel?.text = linkItem.text
                cell.imageView?.image = UIImage(named: linkItem.image)
                
                return cell
            })
        
        return dataSource
    }
    
    func updateSnapshot() {
        
        // create snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, LinkItem>()
        snapshot.appendSections([.feedback, .followus])
        snapshot.appendItems(sectionContent[0], toSection: .feedback)
        snapshot.appendItems(sectionContent[1], toSection: .followus)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            if let indexPath = tableView.indexPathForSelectedRow,
               let destnationController = segue.destination as? WebViewController,
               let linkItem = self.dataSource.itemIdentifier(for: indexPath) {
                
                destnationController.targetURL = linkItem.link
            }
        }
    }

    func openWithSafariViewController(indexPath: IndexPath) {
        guard let linkItem = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        if let url = URL(string: linkItem.link) {
            let safariController = SFSafariViewController(url: url)
            present(safariController, animated: true, completion: nil)
        }
    }
}
