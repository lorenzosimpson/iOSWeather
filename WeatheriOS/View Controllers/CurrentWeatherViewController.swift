//
//  MainViewController.swift
//  weather
//
//  Created by Lorenzo on 3/27/21.
//

import UIKit

class CurrentWeatherViewController: UIViewController, LocationDelegate, ReloadDelegate {
    func locationWasUpdated<T>(with data: T) {
        if let weatherData = data as? WeatherData {
            defaultCity = weatherData.id
            UserDefaults.standard.setValue(defaultCity, forKey: "city")
            
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    
    func reload() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       // navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        createGradient()
        collectionView.dataSource = self
        weatherController.delegate = self
    }
    
    func createGradient() {
        let colorTop =  UIColor(red: 105/255.0, green: 66/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 122/255.0, green: 156/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getWeather()
        NotificationCenter.default.addObserver(self, selector: #selector(getWeather), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    var defaultCity = UserDefaults.standard.value(forKey: "city")
    
    @objc func getWeather() {
        if defaultCity == nil {
            performSegue(withIdentifier: "ShowChooseCitySegue", sender: self)
        } else {
            weatherController.fetchWeatherById(cityId: defaultCity as! Int) { (result) in
                do {
                    let weather = try result.get()
                    DispatchQueue.main.async {
                        self.locationWasUpdated(with: weather)
                    }
                    
                } catch {
                    fatalError("Error getting weather for default location, \(error)")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChooseCitySegue" {
            if let locationVC = segue.destination as? SearchViewController {
                locationVC.locationDelegate = self
                locationVC.weatherController = weatherController
            }
        }
    }
 
  
    
    func updateViews() {
        if let weatherData = weatherController.weather {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: URL(string: "https://openweathermap.org/img/wn/\(weatherData.weather[0].icon)@4x.png")!)
                DispatchQueue.main.async {
                    self.weatherImageView.image = UIImage(data: data!)
                }
            }
            cityLabel.text = weatherData.name
            countryLabel.text = Util().countryCodes[weatherData.sys.country]
            dateLabel.text = weatherController.formatTodayDate()
            let feelsLike = weatherController.convertTemp(temp: weatherData.main.feelsLike, from: .kelvin, to: .fahrenheit)
            feelsLikeLabel.text = feelsLike
           
            let temp = weatherData.main.temp
            temperatureLabel.text = weatherController.convertTemp(temp: temp, from: .kelvin, to: .fahrenheit)
            weatherImageView.image?.withRenderingMode(.alwaysTemplate)
            
            let weatherDescriptions = weatherData.weather[0].main.lowercased()
            weatherImageView.tintColor = .white
            
            let desc = weatherData.weather[0].description.capitalized
            descLabel.text = desc
        }
    }
    
    
   
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var mainConditionLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    private let cache = Cache<String, Data>()
    
    let weatherController = WeatherController()
}

extension CurrentWeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ForecastCollectionViewCell else {
            NSLog("Wrong cell type")
            return UICollectionViewCell()
        }
        var prevDay: List?
        if let day = weatherController.forecast?.list[indexPath.item],
           let city = weatherController.forecast?.city {
            let temp = day.main.temp
            cell.forecastTempLabel.text = weatherController.convertTemp(temp: temp, from: .kelvin, to: .fahrenheit)
           
                DispatchQueue.global().async {
                    let icon = day.weather[0].icon
                    // Implement icon caching so icons are only fetched once
                    if let cachedImageData = self.cache.value(for: icon),
                        let image = UIImage(data: cachedImageData) {
                        DispatchQueue.main.async {
                            cell.iconImageView.image = image
                        }
                        return
                    }
                    
                    do {
                    let data = try Data(contentsOf: URL(string: "https://openweathermap.org/img/wn/\(icon)@4x.png")!)
                        self.cache.cache(value: data, for: icon)
                        
                        DispatchQueue.main.async {
                            cell.iconImageView.image = UIImage(data: data)
                        }
                    } catch {
                        NSLog("Error getting/caching icon, \(error)")
                    }
                }
            
            let date = day.dt
            var prevDayWeek: String?
            let dateTime =  weatherController.convertUnixToDate(with: date, secondsFromGMT: city.timezone!)
            cell.dateLabel.text = ""
            if indexPath.item != 0 {
                prevDay = weatherController.forecast?.list[indexPath.item - 1]
                if prevDay != nil {
                    prevDayWeek = weatherController.convertUnixToDate(with: (prevDay?.dt)!, secondsFromGMT:city.timezone!)[1]
                    if prevDayWeek != dateTime[1] {
                        cell.dateLabel.text = dateTime[1]
                    }
                }
            } else {
                cell.dateLabel.text = dateTime[1]
            }
            
            cell.timeLabel.text = dateTime[0]
            
        }
       
        return cell
    }
    
    
}

