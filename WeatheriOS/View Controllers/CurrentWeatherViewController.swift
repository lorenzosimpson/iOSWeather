//
//  MainViewController.swift
//  weather
//
//  Created by Lorenzo on 3/27/21.
//

import UIKit

class CurrentWeatherViewController: UIViewController, LocationDelegate {
    func locationWasUpdated<T>(with data: T) {
        self.weatherData = data as? WeatherData
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.setNavigationBarHidden(true, animated: false)
        createGradient()
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
    
    let defaultCity = UserDefaults.standard.value(forKey: "city")
    
    @objc func getWeather() {
        if defaultCity == nil {
            performSegue(withIdentifier: "ShowChooseCitySegue", sender: self)
        } else {
            weatherController.fetchWeatherById(cityId: defaultCity as! Int) { (result) in
                do {
                    let weather = try result.get()
                    self.weatherController.setDefaultLocation(cityId: weather.id)
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
            }
        }
        if segue.identifier == "ForecastCollectionViewSegue" {
            if let forecastVC = segue.destination as? ForecastCollectionViewController {
                if defaultCity != nil {
                forecastVC.cityId = defaultCity as? Int
                forecastVC.weatherController = weatherController
                }
            }
        }
    }
    
    var weatherData: WeatherData? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        if let weatherData = weatherData {
            cityLabel.text = weatherData.name
            countryLabel.text = Util().countryCodes[weatherData.sys.country]
            dateLabel.text = weatherController.formatTodayDate()
            
            let temp = weatherData.main.temp
            temperatureLabel.text = weatherController.convertTemp(temp: temp, from: .kelvin, to: .fahrenheit)
            weatherImageView.image?.withRenderingMode(.alwaysTemplate)
            
            let weatherDescriptions = weatherData.weather[0].main.lowercased()
            mainConditionLabel.text = weatherDescriptions.uppercased()
            weatherImageView.tintColor = .white
            
            let desc = weatherData.weather[0].description.capitalized
            descLabel.text = desc
            
            if weatherDescriptions.contains("parly cloudy") {
                weatherImageView.image = UIImage(systemName: "cloud.sun")
            } else if weatherDescriptions.contains("clouds") {
                weatherImageView.image = UIImage(systemName: "cloud")
            } else if weatherDescriptions.contains("sun") {
                weatherImageView.image = UIImage(systemName: "sun")
                weatherImageView.tintColor = .yellow
            } else if weatherDescriptions.contains("clear") {
                weatherImageView.image = UIImage(systemName: "sun.max")
                weatherImageView.tintColor = .yellow
            } else if weatherDescriptions.contains("mist") {
                weatherImageView.image = UIImage(systemName: "cloud.rain")
            } else if weatherDescriptions.contains("rain") {
                weatherImageView.image = UIImage(systemName: "cloud.heavyrain")
            } else if weatherDescriptions.contains("haze") {
                weatherImageView.image = UIImage(systemName: "sun.haze")
            }
        }
    }
    
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var mainConditionLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    let weatherController = WeatherController()
}
