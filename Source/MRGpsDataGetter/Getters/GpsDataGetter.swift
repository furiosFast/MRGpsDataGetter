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
import SwifterSwift

@objc public protocol MRGpsDataGetterGpsDataDelegate: NSObjectProtocol {
    func gpsDataReady(gps: GpsInfoModel)
    @objc optional func setGpsMap(currentLocation: CLLocation)
    @objc optional func reverseGeocodeFromString(location: CLLocation)
    @objc optional func reverseGeocodeFromStringError(error: String)
    func reverseGeocodeFromLocation(locationName: String)
    @objc optional func reverseGeocodeFromLocationError(error: String)
}

open class GpsDataGetter: NSObject {
    
    public static let shared = GpsDataGetter()
    open weak var delegate : MRGpsDataGetterGpsDataDelegate?
    
    lazy var geocoder = CLGeocoder()
    let gps = GpsInfoModel()
    
    
    /// Function that start to retrive all GPS data and the location on name of a specified location
    /// - Parameter currentLocation: location
    open func getPositionInfo(currentLocation: CLLocation) {
        reversePositionInfo(currentLocation)
        DispatchQueue.global().async {
            if self.geocoder.isGeocoding {
                self.geocoder.cancelGeocode()
            }
            self.reverseGeocodeFromLocation(currentLocation)
        }
        DispatchQueue.main.async {
            self.delegate?.setGpsMap?(currentLocation: currentLocation)
        }
    }
    
    /// Private function that start to retrive all GPS data of a specified location
    /// - Parameter currentLocation: location
    private func reversePositionInfo(_ currentLocation: CLLocation){
        gps.latitude = latitudeToString(currentLocation.coordinate.latitude)
        gps.longitude = longitudeToString(currentLocation.coordinate.longitude)
        gps.altitude = String(format: "%3.1f " + loc("METERS"), currentLocation.altitude)
        gps.verticalAccuracy = String(format: "%3.1f " + loc("METERS"), currentLocation.verticalAccuracy)
        gps.horizontalAccuracy = String(format: "%3.1f " + loc("METERS"), currentLocation.horizontalAccuracy)
        gps.course = currentLocation.course.string
        if(currentLocation.speed < 0) {
            if Preferences.shared.getPreference("windSpeed") == "meterSecondSpeed" {
                gps.speed = "0.0 " + loc("METERSSECOND")
            }
            if Preferences.shared.getPreference("windSpeed") == "kilometerHoursSpeed" {
                gps.speed = "0.0 " + loc("KILOMETERSHOUR")
            }
            if Preferences.shared.getPreference("windSpeed") == "knotSpeed" {
                gps.speed = "0.0 " + loc("KNOT")
            }
            if Preferences.shared.getPreference("windSpeed") == "milesHoursSpeed" {
                gps.speed = "0.0 " + loc("MILESHOURS")
            }
        } else {
            if Preferences.shared.getPreference("windSpeed") == "meterSecondSpeed" {
                gps.speed = String(format: "%3.1f " + loc("METERSSECOND"), currentLocation.speed)
            }
            if Preferences.shared.getPreference("windSpeed") == "kilometerHoursSpeed" {
                gps.speed = String(format: "%3.1f " + loc("KILOMETERSHOUR"), currentLocation.speed * meterSecondToKilometerHour)
            }
            if Preferences.shared.getPreference("windSpeed") == "knotSpeed" {
                gps.speed = String(format: "%3.1f " + loc("KNOT"), currentLocation.speed * meterSecondToKnot)
            }
            if Preferences.shared.getPreference("windSpeed") == "milesHoursSpeed" {
                gps.speed = String(format: "%3.1f " + loc("MILESHOURS"), currentLocation.speed * meterSecondToMilesHour)
            }
        }
        
        
        DispatchQueue.main.async {
            self.delegate?.gpsDataReady(gps: self.gps)
        }
    }
    
    /// Get the gps data object
    open func getOldGpsData() -> GpsInfoModel {
        return gps
    }
    
    /// Function that retrieve the location object based on the location name
    /// - Parameter locationAddress: location name
    open func reverseGeocodeFromString(_ locationAddress: String){
        geocoder.geocodeAddressString(locationAddress) { (placemarks, error) in
            if let error = error {
                self.delegate?.reverseGeocodeFromStringError?(error: error.localizedDescription)
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first, let location = placemark.location {
                    self.delegate?.reverseGeocodeFromString?(location: location)
                }
            }
        }
    }
    
    /// Function that retrieve the location name based on the location object
    open func reverseGeocodeFromLocation(_ currentLocation: CLLocation){
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            if let error = error {
                self.delegate?.reverseGeocodeFromLocationError?(error: error.localizedDescription)
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first, let locality = placemark.locality, let isoCountryCode = placemark.isoCountryCode {
                    self.gps.locationName = locality + ", " + isoCountryCode.uppercased()
                } else {
                    if let placemarks = placemarks, let placemark = placemarks.first, let inlandWater = placemark.inlandWater, let ocean = placemark.ocean {
                        self.gps.locationName = ocean + ", " + inlandWater.uppercased()
                    } else {
                        self.gps.locationName = loc("lOCATION_NaN")
                    }
                }
                self.delegate?.reverseGeocodeFromLocation(locationName: self.gps.locationName)
            }
        }
    }
    
    //MARK: - Support functions for gps data
    
    /// Function that format the latitute coord from a double value
    /// - Parameter latitude: the position latitute (in degrees)
    private func latitudeToString(_ latitude: Double) -> String {
        var latSeconds = (latitude * 3600).int
        let latDegrees = latSeconds / 3600
        latSeconds = abs(latSeconds % 3600)
        let latMinutes = latSeconds / 60
        latSeconds %= 60
        return String(format: "%d° %d' %d\" %@", abs(latDegrees), latMinutes, latSeconds, latDegrees >= 0 ? "N" : "S")
    }

    /// Function that format the longitude coord from a double value
    /// - Parameter longitude: the position longitude (in degrees)
    private func longitudeToString(_ longitude: Double) -> String {
        var longSeconds = (longitude * 3600).int
        let longDegrees = longSeconds / 3600
        longSeconds = abs(longSeconds % 3600)
        let longMinutes = longSeconds / 60
        longSeconds %= 60
        return String(format: "%d° %d' %d\" %@", abs(longDegrees), longMinutes, longSeconds, longDegrees >= 0 ? "E" : "W")
    }
    
}
