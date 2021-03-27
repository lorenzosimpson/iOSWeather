//
//  MainViewController.swift
//  weather
//
//  Created by Lorenzo on 3/27/21.
//

import UIKit

class MainViewController: UIViewController, LocationDelegate {
    func locationWasUpdated(with weatherData: WeatherData) {
        self.weatherData = weatherData
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.setNavigationBarHidden(true, animated: true)
        weatherImageView.image?.withRenderingMode(.alwaysTemplate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if weatherData == nil {
            performSegue(withIdentifier: "ShowChooseCitySegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChooseCitySegue" {
            if let locationVC = segue.destination as? ChooseInitialLocationViewController {
                locationVC.lcoationDelegate = self
            }
        }
    }
    
    var weatherData: WeatherData? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let weatherData = weatherData else { fatalError("Could not update UI with weather data") }
        cityLabel.text = weatherData.name
        countryLabel.text = "United States"
        dateLabel.text = "Mar 27, 2021"
        temperatureLabel.text = String(weatherData.main.temp)
        print(weatherData)
        let weatherDescriptions = weatherData.weather[0].main.lowercased()
            if weatherDescriptions.contains("clouds") {
                weatherImageView.image = UIImage(systemName: "cloud")
            } else if weatherDescriptions.contains("sun") {
                weatherImageView.image = UIImage(systemName: "sun")
                weatherImageView.tintColor = .yellow
            } else if weatherDescriptions.contains("clear") {
                weatherImageView.image = UIImage(systemName: "sun.min")
                weatherImageView.tintColor = .yellow
            }
       
    }
    
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
}
