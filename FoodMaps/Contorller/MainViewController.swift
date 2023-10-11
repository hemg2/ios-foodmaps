//
//  MainViewController.swift
//  FoodMaps
//
//  Created by Hemg on 2023/10/09.
//

import UIKit
import CoreLocation

final class MainViewController: UIViewController {
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.placeholder = "식당 검색"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        return searchBar
    }()
    
    private var mapView: MTMapView?
    private var mapPointValue: MTMapPoint?
    private var locationManager = CLLocationManager()
    private var restaurantItems = [RestaurantItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMap()
        setUpLocationManager()
        setUpSearchBarUI()
    }
    
    private func setUpMap() {
        mapView = MTMapView(frame: self.view.frame)
        guard let mapView else { return }
        mapView.delegate = self
        mapView.baseMapType = .standard
        self.view.addSubview(mapView)
    }
    
    private func setUpSearchBarUI() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4)
        ])
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateMapView(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        updateMapView(with: "")
    }
    
    private func updateMapView(with searchText: String) {
        mapView?.removeAllPOIItems()
        let filteredPoiItems: [MTMapPOIItem]
        
        if searchText.isEmpty {
            filteredPoiItems = restaurantItems.map { $0.poiItem }
        } else {
            filteredPoiItems = restaurantItems.filter {
                $0.poiItem.itemName.lowercased().contains(searchText.lowercased())
            }.map { $0.poiItem }
        }
        
        mapView?.addPOIItems(filteredPoiItems)
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
    private func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let userLocation = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
            let userMarker = MTMapPOIItem()
            
            userMarker.itemName = "나의 위치"
            userMarker.mapPoint = userLocation
            userMarker.markerType = .bluePin
            mapView?.addPOIItems([userMarker])
            mapView?.setMapCenter(userLocation, animated: true)
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
        
        let modifiedPOIItem = restaurantItems[index].poiItem
        modifiedPOIItem.itemName = title
        modifiedPOIItem.userObject = description as NSObject
        mapView?.addPOIItems(restaurantItems.map { $0.poiItem })
        mapView?.updateConstraints()
    }
    
    func deletePin(withTag tag: Int) {
        let poiItemToRemove = restaurantItems[tag].poiItem
        restaurantItems.remove(at: tag)
        mapView?.removePOIItems([poiItemToRemove])
    }
}
