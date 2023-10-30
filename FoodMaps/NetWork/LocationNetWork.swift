//
//  LocationNetWork.swift
//  FoodMaps
//
//  Created by Hemg on 10/13/23.
//

final class LocationNetWork {
    private let session: URLSession
    let api = LocationAPI()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getLocation(by mapPoint: MTMapPoint, categoryValue: String, completion: @escaping (Result<Data, URLError>) -> Void) {
        guard let url = api.getLocation(by: mapPoint, categoryValue: categoryValue).url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let request = api.request(url: url)
        
        session.dataTask(with: request) { data, _, error in
            if error != nil {
                completion(.failure(URLError(.cannotLoadFromNetwork)))
            } else if let data = data {
                completion(.success(data))
            }
        }.resume()
    }
    
    func decodeLocationData(data: Data) -> Result<LocationData, URLError> {
        do {
            let locationData = try JSONDecoder().decode(LocationData.self, from: data)
            return .success(locationData)
        } catch {
            return .failure(URLError(.cannotParseResponse))
        }
    }
}
