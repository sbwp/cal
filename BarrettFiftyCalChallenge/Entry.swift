//
//  Entry.swift
//  BeaFiftyCalChallenge
//
//  Created by Sabrina Bea on 3/21/21.
//

import Foundation

struct Entry: Identifiable {
    var date: Date
    var goal: Int64
    var calories: Int64
    
    var id: Int {
        return date.hashValue
    }
    
    static func propertiesEqual(_ lhs: Entry, _ rhs: Entry) -> Bool {
        return lhs.date == rhs.date && lhs.goal == rhs.goal && lhs.calories == rhs.calories
    }
}
