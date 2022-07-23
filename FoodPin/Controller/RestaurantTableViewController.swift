//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/6/2.
//

import UIKit
import CoreData

class RestaurantTableViewController: UITableViewController {

    // MARK: - Properties
    
    var restaurants: [Restaurant] = []
    var fetchResultController: NSFetchedResultsController<Restaurant>!
    var searchController: UISearchController!
    
    lazy var dataSource = configureDataSource()

    // MARK: - IBOutlet
    
    @IBOutlet var emptyRestaurantView: UIView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backButtonTitle = ""
        navigationController?.hidesBarsOnSwipe = true
        
        // custom navigation bar appearance
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
        tableView.tableHeaderView = searchController.searchBar
        tableView.separatorStyle = .none
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        tableView.backgroundView = emptyRestaurantView
        tableView.backgroundView?.isHidden = restaurants.count == 0 ? false : true
        
        searchController.searchResultsUpdater = self
        
        // 控制底下內容於搜尋期間是否變為黯淡狀態
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.tintColor = UIColor(named: "NavBarTitle")
        searchController.searchBar.placeholder = String(localized: "Search...")
        //searchController.searchBar.prompt = "123"
        
        fetchRestaurantData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            return
        }
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthoroughViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
            present(walkthoroughViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Diffable Data Source
    
    func configureDataSource() -> RestaurantDiffableDataSource {
        
        let cellIdentifier = "datacell"
        
        let dataSource = RestaurantDiffableDataSource(
            
            tableView: tableView,
            cellProvider: {tableView, IndexPath, restaurant in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: IndexPath) as! RestaurantTableViewCell
                
                cell.nameLabel?.text = restaurant.name
                cell.locationLabel?.text = restaurant.location
                cell.typeLabel?.text = restaurant.type
                cell.thumbnaiImageView?.image = UIImage(data: restaurant.image)
                cell.favoriteImage.isHidden = restaurant.isFavorite ? false : true
                
                return cell
            }
        )
        
        return dataSource
    }
    
    // MARK: - Snapshot
    
    func updateSnapshot(animatingChange: Bool = false) {
        
        if let fetchedObjects = fetchResultController.fetchedObjects {
            restaurants = fetchedObjects
        }
        
        // create snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Restaurant>()
        snapshot.appendSections([.all])
        snapshot.appendItems(restaurants, toSection: .all)
        
        dataSource.apply(snapshot, animatingDifferences: animatingChange)
        tableView.backgroundView?.isHidden = restaurants.count == 0 ? false : true
    }
    
    // MARK: - 處理「向左滑動」動作
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 搜尋列使用時停用滑動動作
        if searchController.isActive {
            return UISwipeActionsConfiguration()
        }
        
        // 取得所選餐廳
        guard let restaurant = self.dataSource.itemIdentifier(for: indexPath) else {
            return UISwipeActionsConfiguration()
        }
        
        // 刪除動作
        let deleteAction = UIContextualAction(style: .destructive, title: String(localized: "Delete")) {
            (action, sourceView, completionHandler) in
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                
                // delete item
                context.delete(restaurant)
                appDelegate.saveContext()
                
                // update view
                self.updateSnapshot(animatingChange: true)
            }
            
            completionHandler(true)
        }
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        // 分享動作
        let shareAction = UIContextualAction(style: .normal, title: String(localized: "Share")) {
            (action, sourceView, completionHandler) in
            
            let defaultText = String(localized: "Just checking in at ") + restaurant.name
            let activityController: UIActivityViewController
            
            if let imageToShare = UIImage(data: restaurant.image) {
                activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
            }
            else {
                activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            }
            
            // for ipad
            if let popoverController = activityController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            
            self.present(activityController, animated: true)
            completionHandler(true)
        }
        shareAction.backgroundColor = UIColor.systemOrange
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        
        // 設定分享＆刪除為滑動動作
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])       
        return swipeConfiguration
    }
    
    // MARK: - 處理「向右滑動」動作
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 搜尋列使用時停用滑動動作
        if searchController.isActive {
            return UISwipeActionsConfiguration()
        }
        
        let addFavoriteAction = UIContextualAction(style: .destructive, title: "") {
            (action, sourceView, completionHandler) in
            
            let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
            cell.favoriteImage.isHidden = self.restaurants[indexPath.row].isFavorite
            
            self.restaurants[indexPath.row].isFavorite = cell.favoriteImage.isHidden ? false : true
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                appDelegate.saveContext()
            }
            
            completionHandler(true)
        }
        addFavoriteAction.backgroundColor = UIColor.systemYellow
        addFavoriteAction.image = UIImage(systemName: self.restaurants[indexPath.row].isFavorite ? "heart.slash.fill" : "heart.fill")
        
        // 設定為滑動動作
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [addFavoriteAction])
        return swipeConfiguration
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destnationController = segue.destination as! RestaurantDetailViewController
                destnationController.restaurant = self.restaurants[indexPath.row]
                destnationController.hidesBottomBarWhenPushed = true
            }
        }
    }

    @IBAction func closeAddView(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Core Data
    
    func fetchRestaurantData(searchText: String = "") {
        
        // get data
        let fetchRequest: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        }
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                updateSnapshot(animatingChange: searchText.isEmpty ? false : true)
            }
            catch {
                print(error)
            }
        }
    }
    
    // MARK: - UIAlertController
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .actionSheet)
//        if let popoverController = optionMenu.popoverPresentationController {
//
//            if let cell = tableView.cellForRow(at: indexPath) {
//
//                popoverController.sourceView = cell
//                popoverController.sourceRect = cell.bounds
//            }
//        }
//
//        let reserveActionHandler = { (action:UIAlertAction!) -> Void in
//            let alertMesg = UIAlertController(title: "Not available yet", message: "Sorry, this feature is not available yet. Please retry later.", preferredStyle: .alert)
//            alertMesg.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//
//            self.present(alertMesg, animated: true)
//        }
//        let reserveAction = UIAlertAction(title: "Reserve a table", style: .default, handler:reserveActionHandler)
//        optionMenu.addAction(reserveAction)
//
//        let favoriteAction = UIAlertAction(title: self.restaurants[indexPath.row].isFavorite ? "Remove from favorites" : "Mark as favorite", style: .default, handler: {
//
//            (action:UIAlertAction) -> Void in
//
//            let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
//            cell.favoriteImage.isHidden = self.restaurants[indexPath.row].isFavorite
//
//            self.restaurants[indexPath.row].isFavorite = self.restaurants[indexPath.row].isFavorite ? false : true
//        })
//        optionMenu.addAction(favoriteAction)
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        optionMenu.addAction(cancelAction)
//
//        present(optionMenu, animated: true, completion: nil)
//        tableView.deselectRow(at: indexPath, animated: false)
//    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension RestaurantTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
}

// MARK: - UISearchResultsUpdating

extension RestaurantTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
        fetchRestaurantData(searchText: searchText)
    }
}
