//
//  LocationAPI.swift
//  FoodMaps
//
//  Created by Hemg on 10/13/23.
//

import CoreLocation

final class LocationAPI {
    private let scheme = "https"
    private let host = "dapi.kakao.com"
    private let path = "/v2/local/search/category.json"
    
    func getLocation(by location: CLLocationManager) -> URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        if let coordinate = location.location?.coordinate {
            components.queryItems = [
                URLQueryItem(name: "category_group_code", value: "FD6"),
                URLQueryItem(name: "x", value: "\(coordinate.longitude)"),
                URLQueryItem(name: "y", value: "\(coordinate.latitude)"),
                URLQueryItem(name: "radius", value: "500"),
                URLQueryItem(name: "sort", value: "distance")
            ]
        }
        
        return components
    }
    
    func request(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(APIKey.location, forHTTPHeaderField: "Authorization")
        return request
    }
}
