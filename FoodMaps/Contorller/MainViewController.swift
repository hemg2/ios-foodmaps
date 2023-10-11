//
//  MainViewController.swift
//  FoodMaps
//
//  Created by Hemg on 2023/10/09.
//

import UIKit
import CoreLocation

final class MainViewController: UIViewController {
    private var mapView: MTMapView?
    private var mapPointValue: MTMapPoint?
    private var locationManager: CLLocationManager!
    private var restaurantItems: [RestaurantItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMap()
    }
    
    private func setUpMap() {
        mapView = MTMapView(frame: self.view.frame)
        guard let mapView else { return }
        mapView.delegate = self
        mapView.baseMapType = .standard
        self.view.addSubview(mapView)
    }
}

extension MainViewController: MTMapViewDelegate {
    func mapView(_ mapView: MTMapView!, longPressOn mapPoint: MTMapPoint!) {
        self.mapPointValue = mapPoint
        let poiItem = MTMapPOIItem()
        
        let addViewController = AddViewController(mapPoint: mapPoint, index: poiItem.tag)
        let navigationController = UINavigationController(rootViewController: addViewController)
        
        addViewController.delegate = self
        present(navigationController, animated: true)
    }
    
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonRightSideOf poiItem: MTMapPOIItem!) {
        let alertController = UIAlertController(title: "수정", message: "마커 수정", preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "수정진행", style: .default) { [weak self] _ in
            let restaurant = Restaurant(title: poiItem.itemName, description: poiItem.userObject as? String ?? "")
            let addViewController = AddViewController(restaurantList: restaurant, mapPoint: poiItem.mapPoint, index: poiItem.tag)
            let navigationController = UINavigationController(rootViewController: addViewController)
            
            addViewController.delegate = self
            self?.present(navigationController, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alertController.addAction(editAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

extension MainViewController: CLLocationManagerDelegate {
    private func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways,.authorizedWhenInUse:
            print("GPS 권한 설정됨")
        case .restricted,.notDetermined:
            print("GPS 권한 설정되지 않음")
            getLocationUsagePermission()
        case .denied:
            print("GPS 권한 요청 거부됨")
            getLocationUsagePermission()
        default:
            print("GPS:Default")
        }
    }
}

extension MainViewController: AddRestaurant {
    func didAddRestaurants(title: String, description: String) {
        let newRestaurants = Restaurant(title: title, description: description)
        let newPoint = MTMapPOIItem()
        newPoint.itemName = title
        newPoint.userObject = description as NSObject
        newPoint.mapPoint = mapPointValue
        newPoint.markerType = .redPin
        
        if let lastIndex = restaurantItems.last?.poiItem.tag {
            newPoint.tag = lastIndex + 1
        } else {
            newPoint.tag = 0
        }
        
        let restaurantItem = RestaurantItem(restaurant: newRestaurants, poiItem: newPoint)
        restaurantItems.append(restaurantItem)
        mapView?.addPOIItems([newPoint])
        mapView?.setMapCenter(mapPointValue, zoomLevel: 2, animated: true)
    }
    
    func didEditRestaurant(title: String, description: String, index: Int) {
        guard index >= 0 && index < restaurantItems.count else {
            return
        }
        
        restaurantItems[index].restaurant.title = title
        restaurantItems[index].restaurant.description = description
        
        let modifiedPOIItem = restaurantItems.first(where: { $0.poiItem.tag == index })
        modifiedPOIItem?.poiItem.itemName = title
        modifiedPOIItem?.poiItem.userObject = description as NSObject
        mapView?.addPOIItems(restaurantItems.map { $0.poiItem })
        mapView?.updateConstraints()
    }
    
    func deletePin(withTag tag: Int) {
        let poiItemToRemove = restaurantItems[tag].poiItem
        restaurantItems.remove(at: tag)
        mapView?.removePOIItems([poiItemToRemove])
    }
}
