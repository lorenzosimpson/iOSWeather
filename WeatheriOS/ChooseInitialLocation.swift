//
//  ViewController.swift
//  WeatheriOS
//
//  Created by Lorenzo on 3/27/21.
//

import UIKit

class ChooseInitialLocationViewController: UIViewController, UISearchBarDelegate {
    
    let weatherController = WeatherController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
        guard let searchTerm = searchBar.text,
            searchTerm != "" else { return }
        
        weatherController.fetchWeatherByCity(for: searchTerm) { (result) in
            let success = try! result.get()
        
        }
        
    }

}

