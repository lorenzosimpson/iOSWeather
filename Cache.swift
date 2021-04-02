//
//  Cache.swift
//  WeatheriOS
//
//  Created by Lorenzo on 4/2/21.
//

import Foundation
import UIKit

class Cache<Key: Hashable, Value> {
    
    func cache(value: Value, for key: Key) {
        cache[key] = value
    }
    
    func value(for key: Key) -> Value? {
        return cache[key]
    }
    
    private var cache = [Key : Value]()
}
