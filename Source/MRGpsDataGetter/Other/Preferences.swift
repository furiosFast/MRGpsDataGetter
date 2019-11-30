//
//  Preferences.swift
//  MRGpsDataGetter
//
//  Created by Marco Ricca on 20/11/2019
//
//  Created for MRGpsDataGetter in 20/11/2019
//  Using Swift 5.0
//  Running on macOS 10.14
//
//  Copyright © 2019 Fast-Devs Project. All rights reserved.
//


import UIKit

class Preferences: NSObject {

    static let shared = Preferences()
    var prefs = [String : String]()
    
    
    ///Function that return the preferences map
    func getPreference(_ key: String) -> String {
        return prefs[key] ?? "NaN"
    }
    
    ///Function that set the preferences map
    func setPreferences(_ preferences : [String : String]){
        prefs.removeAll()
        prefs = preferences
    }
    
}
