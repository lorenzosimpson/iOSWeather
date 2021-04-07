//
//  ViewController.swift
//  WeatheriOS
//
//  Created by Lorenzo on 3/27/21.
//

import UIKit

protocol LocationDelegate {
    func locationWasUpdated<T>(with data: T)
}

class SearchViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var weatherController: WeatherController?
    var locationDelegate: LocationDelegate?
    var weatherData: WeatherData?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
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
        
        weatherController?.fetchWeatherFromServer(for: city, zip: zip, country: nil) { (result) in
            do {
                let weather = try result.get()
                self.weatherData = weather
                self.locationDelegate?.locationWasUpdated(with: weather)
                
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

extension SearchViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherController?.recents.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityCollectionViewCell.reuseIdentifier, for: indexPath) as? CityCollectionViewCell else { return UICollectionViewCell() }
        
        cell.city = weatherController?.recents[indexPath.item]
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let city = weatherController?.recents[indexPath.item] else { return }
        weatherController?.fetchWeatherById(cityId: (city.id)!, completion: { (result) in
            do {
                let weather = try result.get()
                self.weatherData = weather
                DispatchQueue.main.async {
                    self.locationDelegate?.locationWasUpdated(with: weather)
                    self.dismiss(animated: true, completion: nil)
                }
            } catch {
                print("Error choosing favorite locaiton")
            }
        })
    }
}

