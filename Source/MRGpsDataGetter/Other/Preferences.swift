//
//  PreferencesController.swift
//  iWindRose²
//
//  Created by Marco Ricca on 20/12/2018
//
//  Created for iWindRose² in 20/12/2018
//  Using Swift 4.0
//  Running on macOS 10.14
//
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
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
        prefs = [String : String]()
        prefs = preferences
    }
    
}
