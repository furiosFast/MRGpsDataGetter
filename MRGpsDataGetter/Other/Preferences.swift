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
    
    
    func getPreference(_ key: String) -> String {
        return prefs[key] ?? "NaN"
    }
    
    func setPreferences(_ preferences : [String : String]){
        Preferences.shared.prefs = [String : String]()
        Preferences.shared.prefs = preferences
    }
    
}
