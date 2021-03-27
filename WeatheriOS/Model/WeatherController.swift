//
//  WeatherController.swift
//  weather
//
//  Created by Lorenzo on 3/26/21.
//

import Foundation

enum NetworkError: Error {
    case noData
    case failedDecode
    case other
}


class WeatherController {
    
    
    var weather: WeatherData?
    
    var apiKey: String {
        var keys: NSDictionary?
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
                keys = NSDictionary(contentsOfFile: path)
            return keys!["API Key"] as! String
        }
        return ""
    }
   
    func fetchWeatherByCity(for city: String, completion: @escaping (Result<WeatherData, NetworkError>) -> Void) {
        let queries = [URLQueryItem(name: "q", value: city), URLQueryItem(name: "appId", value: apiKey)]
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
        urlComponents.queryItems = queries
        let url = urlComponents.url!
        print(url)
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error fetching city weather, \(error)")
                completion(.failure(.other))
                return
            }
            guard let data = data else {
                print("No data")
                completion(.failure(.noData))
                return
            }
            print(data)
            do {
            // decode the data
                let decoder = JSONDecoder()
                let cityWeather = try decoder.decode(WeatherData.self, from: data)
                self.weather = cityWeather
                print(cityWeather)
                completion(.success(cityWeather))
            } catch {
                print("Error decoding json, \(error)")
                completion(.failure(.failedDecode))
            }
        }
        task.resume()
        }
}

