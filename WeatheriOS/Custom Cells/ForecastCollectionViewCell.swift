//
//  ForecastCollectionViewCell.swift
//  WeatheriOS
//
//  Created by Lorenzo on 3/29/21.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "cell"
    
    @IBOutlet weak var cellLabel: UILabel!
    
    var content: String? {
        didSet {
            cellLabel.text = "Hello, world"
        }
    }
}
