//
//  DataManager.swift
//  FoodMaps
//
//  Created by Hemg on 10/17/23.
//

final class LocationDataManager {
    static let shared = LocationDataManager()
    private init(){}
    
    var locationData: LocationData?
}
