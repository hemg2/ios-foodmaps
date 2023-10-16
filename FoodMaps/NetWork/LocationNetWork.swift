//
//  LocationNetWork.swift
//  FoodMaps
//
//  Created by Hemg on 10/13/23.
//

import CoreLocation

final class LocationNetWork {
    private let session: URLSession
    let api = LocationAPI()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getLocation(by mapPoint: MTMapPoint, completion: @escaping (Result<LocationData, URLError>) -> Void) {
        guard let url = api.getLocation(by: mapPoint).url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let request = api.request(url: url)
        
        session.dataTask(with: request) { data, _, error in
            if error != nil {
                completion(.failure(URLError(.cannotLoadFromNetwork)))
            }
            
            if let data = data {
                do {
                    let locationData = try JSONDecoder().decode(LocationData.self, from: data)
                    completion(.success(locationData))
                } catch {
                    completion(.failure(URLError(.cannotParseResponse)))
                }
            }
        }.resume()
    }
}
