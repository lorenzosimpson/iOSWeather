//
//  ForecastCollectionViewCell.swift
//  WeatheriOS
//
//  Created by Lorenzo on 3/29/21.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "cell"
    
    @IBOutlet weak var forecastTempLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
}
