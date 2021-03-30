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
    case cityNotFound
}


class WeatherController {
    
    var weather: WeatherData?
    var forecast: ForecastData?
    private var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
    private var urlComponentsForecast = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")!
    
    
    func fetchFetchForecastFromServer(for city: String?, zip: String?, country: String?, completion: @escaping (Result<ForecastData, NetworkError>) -> Void) {
        // If a zip is passed in, make sure it's valid and only numeric
        if (zip != nil) {
           guard let zip = zip, zip.count == 5, Int(zip) != nil else {
            print("Invalid zipcode")
            return
           }
        }
        
        var cityQueries = [URLQueryItem(name: "q", value: city)]
        var zipQueries = [URLQueryItem(name: "q", value: "\(zip ?? ""),us")]
        
        cityQueries.append(URLQueryItem(name: "appId", value: apiKey))
        zipQueries.append(URLQueryItem(name: "appId", value: apiKey))
        
        
        urlComponentsForecast.queryItems = city != nil ? cityQueries : zipQueries
        let url = urlComponentsForecast.url!
        print(url)
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error fetching city weather, \(error)")
                completion(.failure(.other))
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 404 {
                print("City not found")
                completion(.failure(.cityNotFound))
                return
            }
            guard let data = data else {
                print("No data")
                completion(.failure(.noData))
                return
            }
          
            do {
                let decoder = JSONDecoder()
                let forecastData = try decoder.decode(ForecastData.self, from: data)
                self.forecast = forecastData
                print(forecastData)
                completion(.success(forecastData))
                
            } catch {
                print("Error decoding json in forecast fn, \(error)")
                completion(.failure(.failedDecode))
            }
        }
        task.resume()
    }
    
    var apiKey: String {
        var keys: NSDictionary?
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
                keys = NSDictionary(contentsOfFile: path)
            return keys!["API Key"] as! String
        }
        return ""
    }
   
    func fetchWeatherFromServer(for city: String?, zip: String?, country: String?, completion: @escaping (Result<WeatherData, NetworkError>) -> Void) {
        
        // If a zip is passed in, make sure it's valid and only numeric
        if (zip != nil) {
           guard let zip = zip, zip.count == 5, Int(zip) != nil else {
            print("Invalid zipcode")
            return
           }
        }
        
        var cityQueries = [URLQueryItem(name: "q", value: city)]
        var zipQueries = [URLQueryItem(name: "q", value: "\(zip ?? ""),us")]
        
        cityQueries.append(URLQueryItem(name: "appId", value: apiKey))
        zipQueries.append(URLQueryItem(name: "appId", value: apiKey))
        
        
        urlComponents.queryItems = city != nil ? cityQueries : zipQueries
        let url = urlComponents.url!
        print(url)
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error fetching city weather, \(error)")
                completion(.failure(.other))
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 404 {
                print("City not found")
                completion(.failure(.cityNotFound))
                return
            }
            guard let data = data else {
                print("No data")
                completion(.failure(.noData))
                return
            }
          
            do {
                let decoder = JSONDecoder()
                let cityWeather = try decoder.decode(WeatherData.self, from: data)
                self.weather = cityWeather
                print(cityWeather)
                self.fetchFetchForecastFromServer(for: city, zip: zip, country: country) { (result) in
                    try! result.get()
                }
                completion(.success(cityWeather))
                
            } catch {
                print("Error decoding json, \(error)")
                completion(.failure(.failedDecode))
            }
        }
        task.resume()
    }
    
    
    func fetchWeatherById(cityId: Int, completion: @escaping (Result<WeatherData, NetworkError>) -> Void) {
        let idQueries = [URLQueryItem(name: "id", value: String(cityId)),
                         URLQueryItem(name: "appId", value: apiKey)
        ]
        urlComponents.queryItems = idQueries
        
        let url = urlComponents.url!
        print(url)
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error fetching city weather, \(error)")
                completion(.failure(.other))
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 404 {
                print("City not found")
                completion(.failure(.cityNotFound))
                return
            }
            guard let data = data else {
                print("No data")
                completion(.failure(.noData))
                return
            }
          
            do {
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
    
    func formatTodayDate() -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"

        if let date = dateFormatterGet.date(from: dateFormatterGet.string(from: Date())) {
            return dateFormatterPrint.string(from: date)
        } else {
           print("There was an error decoding the string")
            return nil
        }
    }
    
    
    func convertTemp(temp: Double, from inputTempType: UnitTemperature, to outputTempType: UnitTemperature) -> String {
        let mf = MeasurementFormatter()
        mf.numberFormatter.maximumFractionDigits = 0
        mf.unitOptions = .providedUnit
        let input = Measurement(value: temp, unit: inputTempType)
        let output = input.converted(to: outputTempType)
        return mf.string(from: output)
    }
    
    func setDefaultLocation(cityId: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(cityId, forKey: "city")
    }

}



