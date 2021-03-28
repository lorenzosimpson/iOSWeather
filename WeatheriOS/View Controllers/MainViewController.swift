//
//  MainViewController.swift
//  weather
//
//  Created by Lorenzo on 3/27/21.
//

import UIKit

class MainViewController: UIViewController, LocationDelegate {
    
    func locationWasUpdated(with weatherData: WeatherData?) {
        self.weatherData = weatherData
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getWeather()
        NotificationCenter.default.addObserver(self, selector: #selector(getWeather), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func getWeather() {
        let defaultCity = UserDefaults.standard.value(forKey: "city")
        if defaultCity == nil {
            performSegue(withIdentifier: "ShowChooseCitySegue", sender: self)
        } else {
            guard let cityName = UserDefaults.standard.value(forKey: "city") else { return }
            weatherController.fetchWeatherFromServer(for: cityName as! String, zip: nil, country: nil) { (result) in
                do {
                    let weather = try result.get()
                    DispatchQueue.main.async {
                        self.locationWasUpdated(with: weather)
                    }
                    
                } catch {
                    fatalError("Error getting weather for default location")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChooseCitySegue" {
            if let locationVC = segue.destination as? ChooseInitialLocationViewController {
                locationVC.locationDelegate = self
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
            mainConditionLabel.text = weatherDescriptions
            weatherImageView.tintColor = .white
            
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
    
    let weatherController = WeatherController()
}
