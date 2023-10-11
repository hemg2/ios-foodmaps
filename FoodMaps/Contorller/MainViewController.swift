//
//  MainViewController.swift
//  FoodMaps
//
//  Created by Hemg on 2023/10/09.
//

import UIKit
import CoreLocation

protocol MainViewControllerDelegate: AnyObject {
    
}

final class MainViewController: UIViewController {
    
    private var mapView: MTMapView? = nil
    private var mapPointValue: MTMapPoint? = nil
    private var locationManager: CLLocationManager!
    private var poiItems = [MTMapPOIItem]()
    private var restaurantList = [Restaurant]()
    weak var delegate: MainViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showMap()
    }
    
    private func showMap() {
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
        let addViewController = AddViewController(mapPoint: mapPoint)
        let navigationController = UINavigationController(rootViewController: addViewController)
        
        addViewController.delegate = self
        present(navigationController, animated: true)
    }
    
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonRightSideOf poiItem: MTMapPOIItem!) {
        let alertController = UIAlertController(title: "수정", message: "마커 수정", preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "수정진행", style: .default) { [weak self] _ in
            let restaurant = Restaurant(title: poiItem.itemName, description: poiItem.userObject as? String ?? "")
            let addViewController = AddViewController(restaurantList: restaurant, mapPoint: poiItem.mapPoint)
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
        self.restaurantList.append(newRestaurants)
        
        let newPoint = MTMapPOIItem()
        newPoint.itemName = title
        newPoint.userObject = description as NSObject
        newPoint.mapPoint = mapPointValue
        newPoint.markerType = .redPin
        poiItems.append(newPoint)
        mapView?.addPOIItems([newPoint])
        
        mapView?.setMapCenter(mapPointValue, zoomLevel: 2, animated: true)
    }
    
    func didEditRestaurant(title: String, description: String, index: Int) {
        guard let editedPOIItem = poiItems.first(where: { $0.tag == index }) else {
            return
        }
        
        editedPOIItem.itemName = title
        editedPOIItem.userObject = description as NSObject
        
        mapView?.addPOIItems(poiItems)
        mapView?.updateConstraints()
    }
    
    func deletePin(withTag tag: Int) {
        if let index = poiItems.firstIndex(where: {$0.tag == tag}) {
            let poiItem = poiItems[index]
            mapView?.removePOIItems([poiItem])
            poiItems.remove(at: index)
        }
    }
}
