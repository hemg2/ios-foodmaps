//
//  MainViewController.swift
//  FoodMaps
//
//  Created by Hemg on 2023/10/09.
//

import UIKit
import CoreLocation

final class MainViewController: UIViewController {
    private var mainView: MainView { view as! MainView }
    private var mapPointValue = MTMapPoint()
    private var locationManager = CLLocationManager()
    private var restaurantItems = [RestaurantItem]()
    private let locationNetWork = LocationNetWork()
    
    override func loadView() {
        view = MainView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moveToMyLocation()
        setUpLocationManager()
        setUpButtonAction()
    }
    
    private func setUpButtonAction() {
        let locationAction = UIAction { [weak self] _ in
            self?.moveToMyLocation()
        }
        mainView.currentLocationButton.addAction(locationAction, for: .touchUpInside)
        
        let foodStoreAction = UIAction { [weak self] _ in
            self?.fetchLocationData(category: CategoryNamespace.foodStore)
        }
        mainView.foodStoreButton.addAction(foodStoreAction, for: .touchUpInside)
        
        let cafeAction = UIAction { [weak self] _ in
            self?.fetchLocationData(category: CategoryNamespace.cafe)
            
        }
        mainView.cafeButton.addAction(cafeAction, for: .touchUpInside)
        
        let convenienceAction = UIAction { [weak self] _ in
            self?.fetchLocationData(category: CategoryNamespace.convenienceStore)
        }
        mainView.convenienceStoreButton.addAction(convenienceAction, for: .touchUpInside)
        
        let parkingAction = UIAction { [weak self] _ in
            self?.fetchLocationData(category: CategoryNamespace.parking)
        }
        mainView.parkingButton.addAction(parkingAction, for: .touchUpInside)
        
        let listAction = UIAction { [weak self] _ in
            self?.showListView()
        }
        mainView.listButton.addAction(listAction, for: .touchUpInside)
    }
    
    private func moveToMyLocation() {
        if let location = locationManager.location?.coordinate {
            let userLocation = MTMapPoint(geoCoord: .init(latitude: location.latitude, longitude: location.longitude))
            mainView.mapView.setMapCenter(userLocation, animated: true)
        }
    }
    
    private func fetchLocationData(category: String) {
        locationNetWork.getLocation(by: mapPointValue, categoryValue: category) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                let decodingData = self.locationNetWork.decodeLocationData(data: data)
                
                switch decodingData {
                case .success(let locationData):
                    LocationDataManager.shared.locationData = locationData
                    self.addMarkers(for: locationData)
                case .failure(let error):
                    print(error)
                }
                
            case .failure(let error):
                print(error)
            }
        }
        mainView.mapView.removeAllPOIItems()
        let customPins = restaurantItems.map { $0.poiItem }
        mainView.mapView.addPOIItems(customPins)
    }
    
    private func addMarkers(for locationData: LocationData) {
        for item in locationData.documents {
            let poiItem = MTMapPOIItem()
            poiItem.itemName = item.placeName
            if let latitude = Double(item.y), let longitude = Double(item.x) {
                poiItem.mapPoint = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
            }
            poiItem.markerType = .yellowPin
            mainView.mapView.addPOIItems([poiItem])
        }
    }
    
    private func showListView() {
        let listViewController = ListViewController()
        navigationController?.pushViewController(listViewController, animated: true)
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
        mainView.mapView.removeAllPOIItems()
        let filteredPoiItems: [MTMapPOIItem]
        
        if searchText.isEmpty {
            filteredPoiItems = restaurantItems.map { $0.poiItem }
        } else {
            filteredPoiItems = restaurantItems.filter { restaurant in
                let itemName = restaurant.poiItem.itemName.lowercased()
                let lowercasedSearchText = searchText.lowercased()
                return itemName.contains(lowercasedSearchText)
            }.map { $0.poiItem }
        }
        
        mainView.mapView.addPOIItems(filteredPoiItems)
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
            let currentCategory = self?.restaurantItems.first { $0.poiItem.tag == poiItem.tag }?.restaurant.category ?? .korean
            let restaurant = Restaurant(title: poiItem.itemName,
                                        description: poiItem.userObject as? String ?? "",
                                        category: currentCategory)
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
    
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        print("위치가 업데이트 될때마다 호출")
    }
    
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        mapPointValue = mapCenterPoint
    }
}

extension MainViewController: CLLocationManagerDelegate {
    private func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        getLocationUsagePermission()
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
}

extension MainViewController: AddRestaurant {
    func didAddRestaurants(title: String, description: String, category: RestaurantCategory) {
        let newRestaurants = Restaurant(title: title, description: description, category: category)
        let newPoint = MTMapPOIItem()
        newPoint.itemName = title
        newPoint.userObject = description as NSObject
        newPoint.mapPoint = mapPointValue
        
        switch category {
        case .korean:
            newPoint.markerType = .customImage
            newPoint.customImage = UIImage(named: "한국")
        case .chinese:
            newPoint.markerType = .customImage
            newPoint.customImage = UIImage(named: "중국")
        case .japanese:
            newPoint.markerType = .customImage
            newPoint.customImage = UIImage(named: "일본")
        case .western:
            newPoint.markerType = .customImage
            newPoint.customImage = UIImage(named: "미국")
        }
        
        if let lastIndex = restaurantItems.last?.poiItem.tag {
            newPoint.tag = lastIndex + 1
        } else {
            newPoint.tag = 0
        }
        
        let restaurantItem = RestaurantItem(restaurant: newRestaurants, poiItem: newPoint)
        restaurantItems.append(restaurantItem)
        mainView.mapView.addPOIItems([newPoint])
        mainView.mapView.setMapCenter(mapPointValue, zoomLevel: 2, animated: true)
    }
    
    func didEditRestaurant(title: String, description: String, index: Int, category: RestaurantCategory) {
        guard index >= 0 && index < restaurantItems.count else {
            return
        }
        
        let modifiedPOIItem = restaurantItems[index].poiItem
        modifiedPOIItem.itemName = title
        modifiedPOIItem.userObject = description as NSObject
        
        switch category {
        case .korean:
            modifiedPOIItem.markerType = .customImage
            modifiedPOIItem.customImage = UIImage(named: "한국")
        case .chinese:
            modifiedPOIItem.markerType = .customImage
            modifiedPOIItem.customImage = UIImage(named: "중국")
        case .japanese:
            modifiedPOIItem.markerType = .customImage
            modifiedPOIItem.customImage = UIImage(named: "일본")
        case .western:
            modifiedPOIItem.markerType = .customImage
            modifiedPOIItem.customImage = UIImage(named: "미국")
        }
        
        mainView.mapView.addPOIItems(restaurantItems.map{$0.poiItem})
        mainView.mapView.select(modifiedPOIItem, animated: true)
        mainView.mapView.updateConstraints()
    }
    
    func deletePin(withTag tag: Int) {
        guard tag >= 0 && tag < restaurantItems.count else { return }
        
        let poiItemToRemove = restaurantItems[tag].poiItem
        mainView.mapView
            .removePOIItems([poiItemToRemove])
        restaurantItems.remove(at: tag)
        
        for (index, item) in restaurantItems.enumerated() {
            item.poiItem.tag = index
        }
    }
}
