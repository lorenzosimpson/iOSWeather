//
//  CityCode.swift
//  WeatheriOS
//
//  Created by Lorenzo on 3/28/21.
//

import Foundation

struct CityCode: Decodable {
    let id: Int
    let name: String
    let state: String
    let country: String
    
    init(id: Int, name: String, state: String, country: String) {
        self.id = id
        self.name = name
        self.state = state
        self.country = country
    }
}
