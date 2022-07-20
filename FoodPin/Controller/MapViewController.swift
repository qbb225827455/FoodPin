//
//  MapViewController.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/7/5.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    // MARK: - Properties
    
    var resaurant = Restaurant()
    
    // MARK: - IBOutlet
    
    @IBOutlet var mapView: MKMapView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true

        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(resaurant.location, completionHandler: {placemaarks, error in
            if let error = error {
                print(error)
                return
            }
            
            if let placemarks = placemaarks {
                // 取得第一個地點標記
                let placemark = placemarks[0]
                
                // 加上標記
                let annotation = MKPointAnnotation()
                annotation.title = self.resaurant.name
                annotation.subtitle = self.resaurant.type
                
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    
                    // 顯示標記
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        })
    }
    
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "myMarker"
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        var annotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        annotationView?.glyphText = "🍽"
        //annotationView?.glyphImage = UIImage(systemName: "arrowtriangle.down.circle")
        annotationView?.markerTintColor = UIColor.orange
        
        return annotationView
    }
    
}
