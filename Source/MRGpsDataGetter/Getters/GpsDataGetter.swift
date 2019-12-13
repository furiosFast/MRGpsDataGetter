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
    var timeoutGeocodeFromString = Timer()
    var timeoutGeocodeFromLocation = Timer()

    
    /// Function that start to retrive all GPS data of a specified location
    /// - Parameter currentLocation: location
    open func getPositionInfo(currentLocation: CLLocation) {
        reversePositionInfo(currentLocation)
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
    /// - Parameter locationAddress: location address
    open func getGeocodeFromString(locationAddress: String) {
        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }
        reverseGeocodeFromString(locationAddress)
        timeoutGeocodeFromString.invalidate()
        timeoutGeocodeFromString = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(stopGeocodeFromString), userInfo: nil, repeats: false)
    }
    
    /// Private function that retrieve the location object based on the location name
    /// - Parameter locationAddress: location name
    private func reverseGeocodeFromString(_ locationAddress: String){
        geocoder.geocodeAddressString(locationAddress) { (placemarks, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.reverseGeocodeFromStringError?(error: error.localizedDescription)
                }
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first, let location = placemark.location {
                    DispatchQueue.main.async {
                        self.delegate?.reverseGeocodeFromString?(location: location)
                    }
                }
            }
        }
    }
    
    @objc private func stopGeocodeFromString(){
        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }
        self.delegate?.reverseGeocodeFromStringError?(error: "reverseGeocodeFromString timeout error")
    }
    
    
    /// Function that retrieve the location name based on the location object
    /// - Parameter currentLocation: location
    open func getGeocodeFromLocation(currentLocation: CLLocation) {
        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }
        reverseGeocodeFromLocation(currentLocation)
        timeoutGeocodeFromLocation.invalidate()
        timeoutGeocodeFromLocation = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(stopGeocodeFromLocation), userInfo: nil, repeats: false)
    }
    
    /// Private function that retrieve the location name based on the location object
    private func reverseGeocodeFromLocation(_ currentLocation: CLLocation){
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.reverseGeocodeFromLocationError?(error: error.localizedDescription)
                }
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
                DispatchQueue.main.async {
                    self.delegate?.reverseGeocodeFromLocation(locationName: self.gps.locationName)
                }
            }
        }
    }
    
    @objc private func stopGeocodeFromLocation(){
        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }
        self.delegate?.reverseGeocodeFromLocationError?(error: "reverseGeocodeFromLocation timeout error")
    }
    
    //MARK: - Support functions
    
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
