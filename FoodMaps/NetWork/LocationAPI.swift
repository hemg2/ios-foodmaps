//
//  LocationAPI.swift
//  FoodMaps
//
//  Created by Hemg on 10/13/23.
//

final class LocationAPI {
    private let scheme = "https"
    private let host = "dapi.kakao.com"
    private let path = "/v2/local/search/category.json"
    
    func getLocation(by mapPoint: MTMapPoint, categoryValue: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        components.queryItems = [
            URLQueryItem(name: "category_group_code", value: categoryValue),
            URLQueryItem(name: "x", value: "\(mapPoint.mapPointGeo().longitude)"),
            URLQueryItem(name: "y", value: "\(mapPoint.mapPointGeo().latitude)"),
            URLQueryItem(name: "radius", value: "20000"),
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
