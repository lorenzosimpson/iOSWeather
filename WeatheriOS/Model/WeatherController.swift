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

protocol ReloadDelegate {
    func reload()
}

class WeatherController {
    
    var delegate: ReloadDelegate?
    var weather: WeatherData?
    var forecast: ForecastData? {
        didSet {
            delegate?.reload()
        }
    }
    private var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
    private var urlComponentsForecast = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")!
    
    var apiKey: String {
        var keys: NSDictionary?
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
                keys = NSDictionary(contentsOfFile: path)
            return keys!["API Key"] as! String
        }
        return ""
    }
    
    func fetchForecastFromServer(cityId: Int, completion: @escaping (Result<ForecastData, NetworkError>) -> Void) {
        let idQueries = [URLQueryItem(name: "id", value: String(cityId)),
                         URLQueryItem(name: "appId", value: apiKey)
        ]
        urlComponentsForecast.queryItems = idQueries
        
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
                let forecastWeather = try decoder.decode(ForecastData.self, from: data)
                self.forecast = forecastWeather
                print("Got forecast for \(forecastWeather.city)")
                completion(.success(forecastWeather))
                
            } catch {
                print("Error decoding json, \(error)")
                completion(.failure(.failedDecode))
            }
        }
        task.resume()
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
                print("got city weather")
                self.fetchForecastFromServer(cityId: cityWeather.id) { (result) in
                    try! result.get()
                    print("got forecast")
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
                self.fetchForecastFromServer(cityId: cityWeather.id) { (result) in
                    try! result.get()
                    print("got forecast")
                }
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
    
    
    func convertUnixToDate(with timestamp: Int) -> [String] {
        let unixtimeInterval = Double(timestamp)
        let date = Date(timeIntervalSince1970: unixtimeInterval)
        let dateFormatterHr = DateFormatter()
        dateFormatterHr.timeZone = TimeZone(abbreviation: "EST") //Set timezone that you want
        dateFormatterHr.locale = NSLocale.current
        dateFormatterHr.dateFormat = "HH:mm" //Specify your format that you want
        
        
        let dateFormatterDay = DateFormatter()
        dateFormatterDay.timeZone = TimeZone(abbreviation: "EST") //Set timezone that you want
        dateFormatterDay.locale = NSLocale.current
        dateFormatterDay.dateFormat = "MMM d" //Specify your format that you want
        let strDateHr = dateFormatterHr.string(from: date)
        let strDateDay = dateFormatterDay.string(from: date)
        return [strDateHr, strDateDay]
    }

}



