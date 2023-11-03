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
    
    func getLocation(by mapPoint: MTMapPoint, categoryValue: String, completion: @escaping (Result<LocationData, URLError>) -> Void) {
        guard let url = api.getLocation(by: mapPoint, categoryValue: categoryValue).url else {
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


//https://dapi.kakao.com/v2/local/search/category.json?category_group_code=CS2&x=124.84848842774163&y=33.47496890088522&radius=20000&sort=distance

//https://dapi.kakao.com/v2/local/search/category.json?category_group_code=FD6&x=127.055107449003&y=37.5876388514287&radius=20000&sort=distance
