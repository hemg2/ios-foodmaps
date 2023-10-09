//
//  MainViewController.swift
//  FoodMaps
//
//  Created by Hemg on 2023/10/09.
//

import UIKit

class MainViewController: UIViewController, MTMapViewDelegate {
    
    private var mapView: MTMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showMap()
    }
    
    private func showMap() {
        mapView = MTMapView(frame: self.view.frame)
        mapView.delegate = self
        mapView.baseMapType = .standard
        self.view.addSubview(mapView)
    }
}
