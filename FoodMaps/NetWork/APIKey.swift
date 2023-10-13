//
//  APIKey.swift
//  FoodMaps
//
//  Created by Hemg on 10/13/23.
//

enum APIKey {
    static var location: String =  {
        return APIKeyFromPlist(key: "KAKAO_APP_KEY")
    }()
}

extension APIKey {
    private static func APIKeyFromPlist(key: String) -> String {
        var apiKey = ""
        
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            let networkKeys = NSDictionary(contentsOfFile: path)
            
            if let networkKeys = networkKeys {
                apiKey = (networkKeys[key] as? String) ?? ""
            }
        }
        
        return apiKey
    }
}
