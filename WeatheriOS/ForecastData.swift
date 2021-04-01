//
//  ForecastData.swift
//  WeatheriOS
//
//  Created by Lorenzo on 3/30/21.
//

import Foundation

struct ForecastData: Decodable {
    let list: [List]
    let city: City
    
    
    enum Keys: String, CodingKey {
        case list
        case city
        
        enum CityKeys: String, CodingKey {
            case id
            case name
            case country
            case timezone
        }
        
        enum ListKeys: String, CodingKey {
            case dt
            case main
            case weather
            
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
    }
    
    init(city: City, list: [List]) {
        self.city = city
        self.list = list
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        var listContainer = try container.nestedUnkeyedContainer(forKey: .list)
        var listArr: [List] = []

        while !listContainer.isAtEnd {
            let listItemContainer = try listContainer.nestedContainer(keyedBy: Keys.ListKeys.self)
            var thisWeather: [Weather] = []
            let dt = try listItemContainer.decode(Int.self, forKey: .dt)

            let mainContainer = try listItemContainer.nestedContainer(keyedBy: Keys.ListKeys.MainKeys.self, forKey: .main)
                let temp = try mainContainer.decode(Double.self, forKey: .temp)
                let feelsLike = try mainContainer.decode(Double.self, forKey: .feelsLike)
                let tempMin = try mainContainer.decode(Double.self, forKey: .tempMin)
                let tempMax = try mainContainer.decode(Double.self, forKey: .tempMax)
                let pressure = try mainContainer.decode(Int.self, forKey: .pressure)
                let humidity = try mainContainer.decode(Int.self, forKey: .humidity)
            let thisMain = Main(temp: temp, feelsLike: feelsLike, tempMin: tempMin, tempMax: tempMax, pressure: pressure, humidity: humidity)


            var weatherContainerArr = try listItemContainer.nestedUnkeyedContainer(forKey: .weather)

            while !weatherContainerArr.isAtEnd {
                let weather = try weatherContainerArr.nestedContainer(keyedBy: Keys.ListKeys.WeatherKeys.self)
                let id = try weather.decode(Int.self, forKey: .id)
                let description = try weather.decode(String.self, forKey: .description)
                let main = try weather.decode(String.self, forKey: .main)
                let icon = try weather.decode(String.self, forKey: .icon)

                thisWeather.append(Weather(description: description, id: id, icon: icon, main: main))
            }
            listArr.append(List(dt: dt, main: thisMain, weather: thisWeather))
        }

        let cityContainer = try container.nestedContainer(keyedBy: Keys.CityKeys.self, forKey: .city)
        let timezone = try cityContainer.decode(Int.self, forKey: .timezone)
        let country = try cityContainer.decode(String.self, forKey: .country)
        let id = try cityContainer.decode(Int.self, forKey: .id)
        let name = try cityContainer.decode(String.self, forKey: .name)
        
        city = City(name: name, id: id, country: country, timezone: timezone)
        list = listArr
        
    }

}

struct List: Decodable {
    var dt: Int
    var main: Main
    var weather: [Weather]
}

