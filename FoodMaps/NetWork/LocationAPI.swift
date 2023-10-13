//
//  LocationAPI.swift
//  FoodMaps
//
//  Created by Hemg on 10/13/23.
//

struct LocationAPI {
    static let scheme = "https"
    static let host = "dapi.kakao.com"
    static let path = "/v2/local/search/category.json"
    
    func getLocation(by mapPoint: MTMapPoint) -> URLComponents {
        var components = URLComponents()
        components.scheme = LocationAPI.scheme
        components.host = LocationAPI.host
        components.path = LocationAPI.path
        
        components.queryItems = [
            URLQueryItem(name: "category_group_code", value: "FD6"),
            URLQueryItem(name: "x", value: "\(mapPoint.mapPointGeo().longitude)"),
            URLQueryItem(name: "y", value: "\(mapPoint.mapPointGeo().latitude)"),
            URLQueryItem(name: "radius", value: "800"),
            URLQueryItem(name: "sort", value: "distance")
        ]
        
        return components
    }
    
    func request(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(APIKey.location, forHTTPHeaderField: "Authorization")
        return request
    }
}
