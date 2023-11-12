//
//  MainView.swift
//  FoodMaps
//
//  Created by 1 on 10/26/23.
//

import Foundation

final class MainView: UIView {
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.placeholder = "식당 검색"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        return searchBar
    }()
    
    let currentLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let foodStoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("맛집!", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let cafeButton: UIButton = {
        let button = UIButton()
        button.setTitle("카페", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let convenienceStoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("편의점", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let parkingButton: UIButton = {
        let button = UIButton()
        button.setTitle("주차장", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let listButton: UIButton = {
        let button = UIButton()
        button.setTitle("목록", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var mapView = MTMapView()
    private weak var delegate: (UISearchBarDelegate & MTMapViewDelegate)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpMap()
        setUpSearchBarUI()
        setUpButton()
    }
    
    convenience init(delegate: UISearchBarDelegate & MTMapViewDelegate) {
        self.init(frame: .zero)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpMap() {
        mapView = MTMapView(frame: self.frame)
        mapView.delegate = delegate
        mapView.baseMapType = .standard
        self.addSubview(mapView)
        mapView.showCurrentLocationMarker = true
        mapView.currentLocationTrackingMode = .onWithHeadingWithoutMapMoving
    }
    
    private func setUpSearchBarUI() {
        addSubview(searchBar)
        searchBar.delegate = delegate
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor, constant: 80),
            searchBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 4),
            searchBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -4)
        ])
    }
    
    private func setUpButton() {
        addSubview(currentLocationButton)
        addSubview(foodStoreButton)
        addSubview(cafeButton)
        addSubview(convenienceStoreButton)
        addSubview(parkingButton)
        addSubview(listButton)
        
        NSLayoutConstraint.activate([
            currentLocationButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12),
            currentLocationButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            currentLocationButton.widthAnchor.constraint(equalToConstant: 40),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 40),
            
            foodStoreButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            foodStoreButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            foodStoreButton.widthAnchor.constraint(equalToConstant: 50),
            foodStoreButton.heightAnchor.constraint(equalToConstant: 20),
            
            cafeButton.centerYAnchor.constraint(equalTo: foodStoreButton.centerYAnchor),
            cafeButton.leadingAnchor.constraint(equalTo: foodStoreButton.trailingAnchor, constant: 12),
            cafeButton.widthAnchor.constraint(equalToConstant: 50),
            cafeButton.heightAnchor.constraint(equalToConstant: 20),
            
            convenienceStoreButton.centerYAnchor.constraint(equalTo: foodStoreButton.centerYAnchor),
            convenienceStoreButton.leadingAnchor.constraint(equalTo: cafeButton.trailingAnchor, constant: 12),
            convenienceStoreButton.widthAnchor.constraint(equalToConstant: 50),
            convenienceStoreButton.heightAnchor.constraint(equalToConstant: 20),
            
            parkingButton.centerYAnchor.constraint(equalTo: foodStoreButton.centerYAnchor),
            parkingButton.leadingAnchor.constraint(equalTo: convenienceStoreButton.trailingAnchor, constant: 12),
            parkingButton.widthAnchor.constraint(equalToConstant: 50),
            parkingButton.heightAnchor.constraint(equalToConstant: 20),
            
            listButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12),
            listButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            listButton.widthAnchor.constraint(equalToConstant: 40),
            listButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
