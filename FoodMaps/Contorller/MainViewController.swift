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
    
    private let currentLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let requestButton: UIButton = {
        let button = UIButton()
        button.setTitle("맛집!", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private var mapView = MTMapView()
    private var mapPointValue = MTMapPoint()
    private var locationManager = CLLocationManager()
    private var restaurantItems = [RestaurantItem]()
    private let locationNetWork = LocationNetWork()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myLocation()
        setUpMap()
        setUpLocationManager()
        setUpSearchBarUI()
        setUpButton()
    }
    
    private func setUpMap() {
        mapView = MTMapView(frame: self.view.frame)
        mapView.delegate = self
        mapView.baseMapType = .standard
        self.view.addSubview(mapView)
    }
    
    private func setUpSearchBarUI() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4)
        ])
    }
    
    private func setUpButton() {
        view.addSubview(currentLocationButton)
        view.addSubview(requestButton)
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        requestButton.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            currentLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            currentLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            currentLocationButton.widthAnchor.constraint(equalToConstant: 40),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 40),
            
            requestButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            requestButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            requestButton.widthAnchor.constraint(equalToConstant: 40),
            requestButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func currentLocationButtonTapped() {
        myLocation()
    }
    
    @objc func requestButtonTapped() {
        fetchLocationData()
    }
    
    private func myLocation() {
        if let location = locationManager.location?.coordinate {
            let userLocation = MTMapPoint(geoCoord: .init(latitude: location.latitude, longitude: location.longitude))
            mapView.setMapCenter(userLocation, animated: true)
        }
    }
    
    private func fetchLocationData() {
        locationNetWork.getLocation(by: mapPointValue) { [weak self] result in
            switch result {
            case .success(let locationData):
                self?.addMarkers(for: locationData)
            case .failure(let error):
                print(error)
            }
        }
        mapView.removeAllPOIItems()
        let customPins = restaurantItems.map { $0.poiItem }
        mapView.addPOIItems(customPins)
    }
    
    private func addMarkers(for locationData: LocationData) {
        for item in locationData.documents {
            let poiItem = MTMapPOIItem()
            poiItem.itemName = item.placeName
            if let latitude = Double(item.y), let longitude = Double(item.x) {
                poiItem.mapPoint = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
            }
            // 어짜피 초기값은 내위치로 오게되어있다. 로케이션 매니져로 인해서 그러니깐 이제 업데이트 될때 그좌표를 전역으로 넣고 그걸 여기서 변경하면 나타나지 않을까?
            // 뷰하나 해서 나타나게 하자 그렇게해서 category_name ,distance(거리), place_name가게이름, 주소road_address_name 정도? 그럼 커스텀은? 그럼 알럿을 하나더? 아니면 수정으로 가거나 통신받은것은 그냥 상세뷰? 커스텀만 수정하게?
            poiItem.markerType = .bluePin
            mapView.addPOIItems([poiItem])
        }
        print("\(mapPointValue.mapPointGeo().longitude)  \(mapPointValue.mapPointGeo().latitude) 에드 마크")
    }
    
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        print("너 호출은 되니?")
    }
    
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        mapPointValue = mapCenterPoint
        print("\(mapPointValue.mapPointGeo().latitude)인스턴스   \(mapCenterPoint.mapPointGeo().latitude) 메서드 인스턴스")
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
        mapView.removeAllPOIItems()
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
        
        mapView.addPOIItems(filteredPoiItems)
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
}

extension MainViewController: CLLocationManagerDelegate {
    private func setUpLocationManager() {
        locationManager.delegate = self
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
        mapView.addPOIItems([newPoint])
        mapView.setMapCenter(mapPointValue, zoomLevel: 2, animated: true)
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
        
        mapView.addPOIItems(restaurantItems.map{$0.poiItem})
        mapView.select(modifiedPOIItem, animated: true)
        mapView.updateConstraints()
    }
    
    func deletePin(withTag tag: Int) {
        guard tag >= 0 && tag < restaurantItems.count else { return }
        
        let poiItemToRemove = restaurantItems[tag].poiItem
        mapView
            .removePOIItems([poiItemToRemove])
        restaurantItems.remove(at: tag)
        
        for (index, item) in restaurantItems.enumerated() {
            item.poiItem.tag = index
        }
    }
}
