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
                self.collectionView.reloadData()
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
        navigationController?.setNavigationBarHidden(true, animated: false)
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
    @IBOutlet weak var collectionView: UICollectionView!
    
    let weatherController = WeatherController()
}

extension CurrentWeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherController.forecast?.list.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ForecastCollectionViewCell else {
            NSLog("Wrong cell type")
            return UICollectionViewCell()
        }
        if let day = weatherController.forecast?.list[indexPath.item],
           let city = weatherController.forecast?.city {
            let temp = day.main.temp
            cell.forecastTempLabel.text = weatherController.convertTemp(temp: temp, from: .kelvin, to: .fahrenheit)
            
            let date = day.dt
            let dateTime =  weatherController.convertUnixToDate(with: date, secondsFromGMT: city.timezone!)
            cell.dateLabel.text = dateTime[1]
            cell.timeLabel.text = dateTime[0]
            
        }
       
        return cell
    }
    
    
}

