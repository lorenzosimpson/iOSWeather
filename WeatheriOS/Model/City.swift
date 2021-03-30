//
//  City.swift
//  weather
//
//  Created by Lorenzo on 3/26/21.
//

import Foundation

struct City: Decodable {
    var name: String
    var id: Int?
    var country: String?
}
