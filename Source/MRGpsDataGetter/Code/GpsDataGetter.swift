//
//  GpsDataGetter.swift
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
import CoreLocation
import MapKit

public protocol MRGpsDataGetterGpsDataDelegate: NSObjectProtocol {
    func gpsDataReady(gps: GpsInfoModel)
    func gpsLocationName(locationName: String)
    func gpsLocation(location: CLLocation)
    func gpsGeocodeAddressFromStringError(error: String)
}

open class GpsDataGetter: NSObject {
    
    public static let shared = GpsDataGetter()

    open weak var delegate : MRGpsDataGetterGpsDataDelegate? = nil
    lazy var geocoder = CLGeocoder()
    let gps = GpsInfoModel()
    
    
    open func getPositionInfo(currentLocation: CLLocation) {
        DispatchQueue.global().async {
            self.reversePositionInfo(currentLocation)
        }
    }
    
    private func reversePositionInfo(_ currentLocation: CLLocation){
        gps.latitudine = "\(latitudeToString(currentLocation.coordinate.latitude))"
        gps.longitudine = "\(longitudeToString(currentLocation.coordinate.longitude))"
        gps.altitudine = String(format: "%3.1f " + loc("METERS"), currentLocation.altitude)
        gps.precisione = "\(currentLocation.horizontalAccuracy)"
        if(currentLocation.speed < 0) {
            if Preferences.shared.getPreference("windSpeed") == "meterSecondSpeed" {
                gps.velocita = "0.0 " + loc("METERSSECOND")
            }
            if Preferences.shared.getPreference("windSpeed") == "kilometerHoursSpeed" {
                gps.velocita = "0.0 " + loc("KILOMETERSHOUR")
            }
            if Preferences.shared.getPreference("windSpeed") == "knotSpeed" {
                gps.velocita = "0.0 " + loc("KNOT")
            }
            if Preferences.shared.getPreference("windSpeed") == "milesHoursSpeed" {
                gps.velocita = "0.0 " + loc("MILESHOURS")
            }
        } else {
            if Preferences.shared.getPreference("windSpeed") == "meterSecondSpeed" {
                gps.velocita = String(format: "%3.1f " + loc("METERSSECOND"), currentLocation.speed)
            }
            if Preferences.shared.getPreference("windSpeed") == "kilometerHoursSpeed" {
                gps.velocita = String(format: "%3.1f " + loc("KILOMETERSHOUR"), currentLocation.speed * meterSecondToKilometerHour)
            }
            if Preferences.shared.getPreference("windSpeed") == "knotSpeed" {
                gps.velocita = String(format: "%3.1f " + loc("KNOT"), currentLocation.speed * meterSecondToKnot)
            }
            if Preferences.shared.getPreference("windSpeed") == "milesHoursSpeed" {
                gps.velocita = String(format: "%3.1f " + loc("MILESHOURS"), currentLocation.speed * meterSecondToMilesHour)
            }
        }
        DispatchQueue.main.async {
            self.delegate?.gpsDataReady(gps: self.gps)
        }
    }
    
    open func getOldGpsData() -> GpsInfoModel {
        return gps
    }
    
    open func geocodeAddressFromString(_ locationAddress: String){
        geocoder.geocodeAddressString(locationAddress) { (placemarks, error) in
            if let error = error {
                self.delegate?.gpsGeocodeAddressFromStringError(error: error.localizedDescription)
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first, let location = placemark.location {
                    self.delegate?.gpsLocation(location: location)
                }
            }
        }
    }
    
    open func reverseGeocodeLocation(_ currentLocation: CLLocation){
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            if let placemarks = placemarks, let placemark = placemarks.first, let locality = placemark.locality, let isoCountryCode = placemark.isoCountryCode {
                self.gps.localita = locality + ", " + isoCountryCode.uppercased()
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first, let inlandWater = placemark.inlandWater, let ocean = placemark.ocean {
                    self.gps.localita = ocean + ", " + inlandWater.uppercased()
                } else {
                    self.gps.localita = loc("position_lOCNAMENAN")
                }
            }
            self.delegate?.gpsLocationName(locationName: self.gps.localita)
        }
    }
    
}
