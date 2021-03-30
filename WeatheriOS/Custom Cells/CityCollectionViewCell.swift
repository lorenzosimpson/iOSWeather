//
//  CityCollectionViewCell.swift
//  weather
//
//  Created by Lorenzo on 3/26/21.
//

import UIKit

class CityCollectionViewCell: UICollectionViewCell {
    private var nameLabel = UILabel()
    private var imageView = UIImageView()
    
    static let reuseIdentifier = "CityCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
    }
    
    // This init method is required, but since we're not going to use it
    // (mostly used by storyboard), we'll warn others not to use it by adding
    // the fatalError call (which intentionally crashes the app).
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    var city: City? {
        didSet {
            guard let city = city else { return }
            nameLabel.text = city.name
            imageView.image = UIImage(named: "Earth")
            setUpSubviews()
        }
    }
    
    func setUpSubviews() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        
        NSLayoutConstraint(item: imageView,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self,
                           attribute: .top,
                           multiplier: 1,
                           constant: 4).isActive = true
        NSLayoutConstraint(item: imageView,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 4).isActive = true
        // width
        NSLayoutConstraint(item: imageView,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: self,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: -4).isActive = true
        // height
        NSLayoutConstraint(item: imageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: imageView,
                           attribute: .width,
                           multiplier: 1,
                           constant: 0).isActive = true
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textAlignment = .center
        
        self.addSubview(nameLabel)
        
        nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                           constant: 2).isActive = true
        
        // Y
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,
                                       constant: 4).isActive = true
        
        // width
        nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                            constant: -2).isActive = true
        
       
    }
}
