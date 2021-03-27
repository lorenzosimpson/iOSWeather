//
//  ViewController.swift
//  WeatheriOS
//
//  Created by Lorenzo on 3/27/21.
//

import UIKit

protocol LocationDelegate {
    func locationWasUpdated(with weatherData: WeatherData)
}

class ChooseInitialLocationViewController: UIViewController, UISearchBarDelegate {

    
    let weatherController = WeatherController()
    var locationDelegate: LocationDelegate?
    var weatherData: WeatherData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
    }
    
     override func viewWillDisappear(_ animated: Bool) {
        locationDelegate?.locationWasUpdated(with: weatherData!)
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    func setDefaultLocation(city: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(city, forKey: "city")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
        guard let searchTerm = searchBar.text,
            searchTerm != "" else { return }
        
        weatherController.fetchWeatherByCity(for: searchTerm) { (result) in
            do {
                let weather = try result.get()
                self.weatherData = weather
                self.setDefaultLocation(city: weather.name)
                
                    DispatchQueue.main.async {
                        self.locationDelegate?.locationWasUpdated(with: weather)
                        self.dismiss(animated: true, completion: nil)
                    }
                
            } catch {
                print("Error dismissing")
            }
        
        }
        
    }

}

