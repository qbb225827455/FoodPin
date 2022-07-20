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
    
    var nowCursor: CKQueryOperation.Cursor?
    var tempCursor: CKQueryOperation.Cursor?
    var fetchTime: Int = 0
    
    // MARK: - IBOutlet
    
    @IBOutlet var btnLoadMore: UIButton!
    
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
        
        btnLoadMore.addTarget(self, action: #selector(loadMoreFromCloud), for: .touchUpInside)
        if restaurants.count == 0 {
            btnLoadMore.isHidden = true
        }
    }
    
    // MARK: - Fetch record from Cloud
    
    @objc func fetchRecordFromCloudOperationalAPI() {
        
        self.fetchTime += 1
        
        // fetch date use Operational API
        let cloudContainer = CKContainer.default()
        let pubDatabase = cloudContainer.publicCloudDatabase
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 5
        queryOperation.recordMatchedBlock = {recordID, result -> Void in
            do {
                if let _ = self.restaurants.first(where: {$0.recordID == recordID}) {
                    return
                }
                print(try? result.get().object(forKey: "name"))
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
            if fetchTime == 1 {
                if cursor != nil {
                    self.tempCursor = cursor
                }
                self.nowCursor = cursor
            }
            
            updateSnapshot()
            
            // explain "https://ithelp.ithome.com.tw/articles/10204233"
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                
                if let refreshControl = self.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
                
                if self.restaurants.count != 0 {
                    self.btnLoadMore.isHidden = false
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
    
    // MARK: - Load more from Cloud
    
    @objc func loadMoreFromCloud() {
        
        btnLoadMore.configuration?.showsActivityIndicator = true
        btnLoadMore.setTitle("", for: .normal)
        
        // fetch date use Operational API
        let cloudContainer = CKContainer.default()
        let pubDatabase = cloudContainer.publicCloudDatabase
        
        if nowCursor == nil {
            nowCursor = tempCursor
        }
        
        if let cursor = self.nowCursor {
            
            let nextQueryOperation = CKQueryOperation(cursor: cursor)
            nextQueryOperation.desiredKeys = ["name"]
            nextQueryOperation.queuePriority = .veryHigh
            nextQueryOperation.resultsLimit = 5
            nextQueryOperation.recordMatchedBlock = {recordID, result -> Void in
                do {
                    if let _ = self.restaurants.first(where: {$0.recordID == recordID}) {
                        return
                    }
                    print("Load more ---\(try? result.get().object(forKey: "name"))")
                    self.restaurants.append(try result.get())
                } catch {
                    print(error)
                }
            }
            
            nextQueryOperation.queryCompletionBlock = { [unowned self] cursor, error -> Void in
                
                if let error = error {
                    print("Failed to get data from iCloud - \(error.localizedDescription)")
                    
                    return
                }
                if cursor != nil {
                    self.tempCursor = cursor
                }
                self.nowCursor = cursor
                
                DispatchQueue.main.async {
                    btnLoadMore.configuration?.showsActivityIndicator = false
                    btnLoadMore.setTitle("Load more ...", for: .normal)
                }
                
                updateSnapshot()
            }
            
            pubDatabase.add(nextQueryOperation)
        }
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
