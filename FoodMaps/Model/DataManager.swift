//
//  DataManager.swift
//  FoodMaps
//
//  Created by Hemg on 10/17/23.
//

final class DataManager {
    static let shared = DataManager()
    private init(){}
    
    var locationData: LocationData?
}
