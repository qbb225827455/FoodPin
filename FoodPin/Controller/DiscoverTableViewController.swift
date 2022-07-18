//
//  DiscoverTableViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/18.
//

import UIKit
import ClockKit
import CloudKit

class DiscoverTableViewController: UITableViewController {

    // MARK: Properties
    
    lazy var dataSource = configureDataSource()
    var restaurants: [CKRecord] = []
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
        
//        Task.init(priority: .high) {
//            do {
//                try await fetchRecordFromCloudConvenienceAPI()
//            } catch{
//                print(error)
//            }
//        }
        
        fetchRecordFromCloudOperationalAPI()
        
        tableView.dataSource = dataSource
    }
    
    // MARK: Fetch record from Cloud
    
    func fetchRecordFromCloudOperationalAPI() {
        
        // fetch date use Operational API
        let cloudContainer = CKContainer.default()
        let pubDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name", "image"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50
        queryOperation.recordMatchedBlock = {recordID, result -> Void in
            do {
                self.restaurants.append(try result.get())
            } catch {
                print(error)
            }
        }
        
        queryOperation.queryCompletionBlock = { [unowned self] cursor, error -> Void in
            
            if let error = error {
                print("Failed to get data from iCloud - \(error.localizedDescription)")
                
                return
            }
            
            print("Successfully retrieve the data from iCloud")
            
            updateSnapshot()
        }
        
        pubDatabase.add(queryOperation)
    }
    
    func fetchRecordFromCloudConvenienceAPI() async throws {
        
        // fetch date use Convenience API
        let cloudContainer = CKContainer.default()
        let pubDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        
        let results = try await pubDatabase.records(matching: query)
        
        for record in results.matchResults {
            self.restaurants.append(try record.1.get())
        }
        
        updateSnapshot()
    }
    
    // MARK: Diffable Data Source
    
    func configureDataSource() -> UITableViewDiffableDataSource<Section, CKRecord> {
        
        let cellIdentifier = "discovercell"
        
        let dataSource = UITableViewDiffableDataSource<Section, CKRecord>(
            
            tableView: tableView,
            cellProvider: {tableView, indexPath, restaurant in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
                cell.textLabel?.text = restaurant.object(forKey: "name")  as? String
                
                if let image = restaurant.object(forKey: "image"),
                   let imageAsset = image as? CKAsset {
                    
                    if let imageData = try? Data.init(contentsOf: imageAsset.fileURL!) {
                        cell.imageView?.image = UIImage(data: imageData)
                    }
                }
            
                return cell
            })
        
        return dataSource
    }
    
    // MARK: Snapshot
    
    func updateSnapshot(animatingChange: Bool = false) {
        
        // create snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, CKRecord>()
        snapshot.appendSections([.all])
        snapshot.appendItems(restaurants, toSection: .all)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }

}
