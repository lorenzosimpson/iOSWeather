//
//  ViewController.swift
//  WeatheriOS
//
//  Created by Lorenzo on 3/27/21.
//

import UIKit

protocol LocationDelegate {
    func locationWasUpdated(with weatherData: WeatherData?)
}

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    let weatherController = WeatherController()
    var locationDelegate: LocationDelegate?
    var weatherData: WeatherData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationDelegate?.locationWasUpdated(with: weatherData)
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text,
              searchTerm != "" else { return }
        var city: String? = nil
        var zip: String? = nil
        
        city = searchTerm
        
        if searchTerm.count == 5, Int(searchTerm) != nil {
            zip = searchTerm
            city = nil
        }
        
        weatherController.fetchWeatherFromServer(for: city, zip: zip, country: nil) { (result) in
            do {
                let weather = try result.get()
                self.weatherData = weather
                self.weatherController.setDefaultLocation(cityId: weather.id)
                
                DispatchQueue.main.async {
                    self.locationDelegate?.locationWasUpdated(with: weather)
                    self.dismiss(animated: true, completion: nil)
                }
            } catch {
                if let error = error as? NetworkError {
                    var errorTitle: String = ""
                    var errorMessage: String = ""
                    switch error {
                    case .cityNotFound:
                        errorTitle = "City not found"
                        errorMessage = "Please check spelling and try again."
                        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    case .failedDecode:
                        NSLog("Failed to decode JSON")
                        
                    case .other:
                        errorTitle = "An error occured"
                        errorMessage = "Please try again"
                        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
}

