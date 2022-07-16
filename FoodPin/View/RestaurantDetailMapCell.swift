//
//  RestaurantDetailSeparatorCell.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/5.
//

import UIKit
import MapKit

class RestaurantDetailMapCell: UITableViewCell {

    // MARK: IBOutlet
    
    @IBOutlet var mapView: MKMapView! {
        didSet {
            // ch.16=exercise1 MapView四周圓角
            mapView.layer.cornerRadius = 20
            mapView.clipsToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //MARK: Function
    
    /// 在 Restaurant Detail View 的 地圖上顯示所選餐廳的位置
    /// - Parameter location: 所選餐廳的地址
    func configure(location: String) {
        // 取得位置
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location, completionHandler: {placemaarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let placemarks = placemaarks {
                // 取得第一個地點標記
                let placemark = placemarks[0]
                
                // 加上標記
                let annotation = MKPointAnnotation()
                if let location = placemark.location {
                    // 顯示標記
                    annotation.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    // 設定縮放
                    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
                    self.mapView.setRegion(region, animated: false)
                }
            }
        })
    }

}
