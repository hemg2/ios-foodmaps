//
//  MainViewController.swift
//  FoodMaps
//
//  Created by Hemg on 2023/10/09.
//

import UIKit
import CoreLocation

final class MainViewController: UIViewController {
    
    private var mapView: MTMapView? = nil
    private var mapPointValue: MTMapPoint? = nil
    private var locationManager: CLLocationManager!
    private var latitude: Double?
    private var longitude: Double?
    private var poiItems = [MTMapPOIItem]()
    private var restaurantList = [Restaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showMap()
        firstLocationPoint()
        showLocationTest()
        changedLocation()
    }
    
    private func showMap() {
        mapView = MTMapView(frame: self.view.frame)
        guard let mapView else { return }
        mapView.delegate = self
        mapView.baseMapType = .standard
        self.view.addSubview(mapView)
    }
    
    private func firstLocationPoint() {
        let firstPoint = MTMapPOIItem()
        let locationOne = MTMapPointGeo(latitude: 37.498206, longitude: 127.02761)
        
        firstPoint.itemName = "강남역"
        firstPoint.mapPoint = MTMapPoint(geoCoord: locationOne)
        firstPoint.markerType = .bluePin
        
        let secondPoint = MTMapPOIItem()
        
        secondPoint.itemName = "지금 위치"
        secondPoint.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.498206, longitude: 127.02765))
        secondPoint.markerType = .yellowPin
        
        let home = MTMapPOIItem()
        
        home.itemName = "집이다"
        home.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.5875041, longitude: 127.0565394))
        home.markerType = .bluePin
        
        mapView?.addPOIItems([firstPoint, secondPoint, home])
    }
}

extension MainViewController: MTMapViewDelegate {
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        self.mapPointValue = mapPoint
        let addViewController = AddViewController(mapPoint: mapPoint)
        let navigationController = UINavigationController(rootViewController: addViewController)
        
        addViewController.delegate = self
        present(navigationController, animated: true)
    }
    
    func mapView(_ mapView: MTMapView!, longPressOn mapPoint: MTMapPoint!) {
        let tappedCoordinate = mapPoint.mapPointGeo()
        
        for (index, poiItem) in poiItems.enumerated() {
            let poiCoordinate = poiItem.mapPoint.mapPointGeo()
            if coordinatesEqual(poiCoordinate, tappedCoordinate) {
                print("삭제할 핀을 찾았습니다")
                mapView.removePOIItems([poiItem])
                poiItems.remove(at: index)
                break
            }
        }
    }
    
    private func coordinatesEqual(_ first: MTMapPointGeo, _ second: MTMapPointGeo) -> Bool {
        return first.latitude == second.latitude && first.longitude == second.longitude
    }
    
    func addDeleteButtonToPin(_ poiItem: MTMapPOIItem) {
        let deleteButton = UIButton(type: .custom)
        deleteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        deleteButton.setTitle("삭제", for: .normal)
        deleteButton.tag = poiItem.tag
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        poiItem.customCalloutBalloonView = deleteButton
    }
    
    @objc func deleteButtonTapped(_ sender: UIButton) {
        let tag = sender.tag
        if let index = poiItems.firstIndex(where: { $0.tag == tag }) {
            let poiItem = poiItems[index]
            mapView?.removePOIItems([poiItem])
            poiItems.remove(at: index)
        }
    }
}

extension MainViewController: CLLocationManagerDelegate {
    private func showLocationTest() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func changedLocation() {
        guard let latitude,
              let longitude else { return }
        let locationNow = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "ko-kr")
        
        geocoder.reverseGeocodeLocation(locationNow, preferredLocale: locale) { (placeMarks, error) in
            if let address: [CLPlacemark] = placeMarks {
                if let country: String = address.last?.country { print(country) }
                if let administrativeArea: String = address.last?.administrativeArea { print(administrativeArea)}
                if let locality: String = address.last?.locality { print(locality) }
                if let name: String = address.last?.name { print(name) }
            }
        }
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
        guard let location = locations.last else { return }
        let longitude: CLLocationDegrees = location.coordinate.longitude
        let latitude: CLLocationDegrees = location.coordinate.latitude
        self.longitude = longitude
        self.latitude = latitude
    }
}

extension MainViewController: AddRestaurant {
    func didAddRestaurants(title: String, description: String) {
        let newRestaurants = Restaurant(title: title, description: description)
        self.restaurantList.append(newRestaurants)
        
        let newPoint = MTMapPOIItem()
        newPoint.itemName = title
        newPoint.mapPoint = mapPointValue
        newPoint.markerType = .redPin
        mapView?.addPOIItems([newPoint])
        
        mapView?.setMapCenter(mapPointValue, zoomLevel: 2, animated: true)
    }
    
    func didEditRestaurant(title: String, description: String, index: Int) {
        print("아직 미정")
    }
}
