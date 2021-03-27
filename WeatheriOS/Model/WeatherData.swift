//
//  WeatherData.swift
//  weather
//
//  Created by Lorenzo on 3/26/21.
//

import Foundation


struct WeatherData: Decodable {
    let name: String
    let weather: [Weather]
    let main: Main
    
    enum Keys: String, CodingKey {
        case name
        case weather
        case main
        
        enum WeatherKeys: String, CodingKey {
            case id
            case main
            case description
            case icon
        }
        
        enum MainKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case humidity
        }
    }
    
    init(name: String, weather: [Weather], main: Main) {
        self.name = name
        self.weather = weather
        self.main = main
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        var weatherContainer = try container.nestedUnkeyedContainer(forKey: .weather)
        var weatherArr: [Weather] = []
        
        while !weatherContainer.isAtEnd {
            // Make container for the weather object
            let weather = try weatherContainer.nestedContainer(keyedBy: Keys.WeatherKeys.self)
            let id = try weather.decode(Int.self, forKey: .id)
            let description = try weather.decode(String.self, forKey: .description)
            let main = try weather.decode(String.self, forKey: .main)
            let icon = try weather.decode(String.self, forKey: .icon)
            weatherArr.append(Weather(description: description,
                                      id: id,
                                      icon: icon,
                                      main: main))
        }
        weather = weatherArr
        
        
        let mainContainer = try container.nestedContainer(keyedBy: Keys.MainKeys.self, forKey: .main)
        let temp = try mainContainer.decode(Double.self, forKey: .temp)
        let feelsLike = try mainContainer.decode(Double.self, forKey: .feelsLike)
        let tempMin = try mainContainer.decode(Double.self, forKey: .tempMin)
        let tempMax = try mainContainer.decode(Double.self, forKey: .tempMax)
        let pressure = try mainContainer.decode(Int.self, forKey: .pressure)
        let humidity = try mainContainer.decode(Int.self, forKey: .humidity)
        
        main = Main(temp: temp, feelsLike: feelsLike, tempMin: tempMin, tempMax: tempMax, pressure: pressure, humidity: humidity)
        
        name = try container.decode(String.self, forKey: .name)
    }

    
}

struct Main: Decodable {
    var temp: Double
    var feelsLike: Double
    var tempMin: Double
    var tempMax: Double
    var pressure: Int
    var humidity: Int
}


struct Weather: Decodable {
    var description: String
    var id: Int
    var icon: String
    var main: String
}
