//
//  DiscoverTableViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/18.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {

    // MARK: - Properties
    
    private var imageCache = NSCache<CKRecord.ID, NSURL>()
    
    lazy var dataSource = configureDataSource()
    
    var restaurants: [CKRecord] = []
    var spinner = UIActivityIndicatorView()
    
    // MARK: - Lifecycle
    
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
        
        // add activity indicator
        spinner.style = .medium
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        // spinner layout
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150.0).isActive = true
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        spinner.startAnimating()
        
        // 下拉更新控制元件
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordFromCloudOperationalAPI), for: UIControl.Event.valueChanged)
    }
    
    // MARK: - Fetch record from Cloud
    
    @objc func fetchRecordFromCloudOperationalAPI() {
        
        // fetch date use Operational API
        let cloudContainer = CKContainer.default()
        let pubDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50
        queryOperation.recordMatchedBlock = {recordID, result -> Void in
            do {
                if let _ = self.restaurants.first(where: {$0.recordID == recordID}) {
                    return
                }
                
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
            
            // explain "https://ithelp.ithome.com.tw/articles/10204233"
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                
                if let refreshControl = self.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
            }
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
    
    // MARK: - Diffable Data Source
    
    func configureDataSource() -> UITableViewDiffableDataSource<Section, CKRecord> {
        
        let cellIdentifier = "discovercell"
        
        let dataSource = UITableViewDiffableDataSource<Section, CKRecord>(
            
            tableView: tableView,
            cellProvider: {tableView, indexPath, restaurant in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
                cell.textLabel?.text = restaurant.object(forKey: "name")  as? String
                
                // 預設圖片設定
                cell.imageView?.image = UIImage(systemName: "photo.fill")
                cell.imageView?.tintColor = .black
                
                // 確認圖片有無快取
                if let imageURL = self.imageCache.object(forKey: restaurant.recordID) {
                    
                    print("Get image from cache")
                    if let imageData = try? Data.init(contentsOf: imageURL as URL) {
                        cell.imageView?.image = UIImage(data: imageData)
                    }
                }
                else {
                    
                    // 背景取得圖片
                    let cloudContainer = CKContainer.default()
                    let pubDatabase = cloudContainer.publicCloudDatabase
                    
                    let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [restaurant.recordID])
                    fetchRecordsImageOperation.desiredKeys = ["image"]
                    fetchRecordsImageOperation.queuePriority = .veryHigh
                    
                    fetchRecordsImageOperation.perRecordResultBlock = {recordID, result in
                        
                        do {
                            let restaurantRecord = try result.get()
                            
                            if let image = restaurantRecord.object(forKey: "image"),
                               let imageAsset = image as? CKAsset {
                                
                                if let imageData = try? Data.init(contentsOf: imageAsset.fileURL!) {
                                    DispatchQueue.main.async {
                                        cell.imageView?.image = UIImage(data: imageData)
                                        cell.setNeedsLayout()
                                    }
                                    
                                    // 加入圖片URL至快取
                                    self.imageCache.setObject(imageAsset.fileURL! as NSURL, forKey: restaurant.recordID)
                                }
                            }
                        } catch {
                            print("Fail to get image - \(error.localizedDescription)")
                        }
                    }
                    
                    pubDatabase.add(fetchRecordsImageOperation)
                }

                return cell
            })
        
        return dataSource
    }
    
    // MARK: - Snapshot
    
    func updateSnapshot(animatingChange: Bool = false) {
        
        // create snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, CKRecord>()
        snapshot.appendSections([.all])
        snapshot.appendItems(restaurants, toSection: .all)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }

}
