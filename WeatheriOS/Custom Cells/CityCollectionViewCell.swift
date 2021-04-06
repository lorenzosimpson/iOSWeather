//
//  CityCollectionViewCell.swift
//  weather
//
//  Created by Lorenzo on 3/26/21.
//

import UIKit

class CityCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CityCell"
    
    var city: City? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        let cityLabel = UILabel(frame: CGRect(x: 0, y: 20, width: 120, height: 25))
        cityLabel.center = self.contentView.center
        cityLabel.textAlignment = .center
        
       
        guard let city = city else { return }
        print(city.name)
        cityLabel.text = city.name
        contentView.addSubview(cityLabel)
    }
    
    @IBOutlet weak var cityNameLabel: UILabel!
    
}
