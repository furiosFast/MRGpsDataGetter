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

@objc public protocol MRGpsDataGetterDelegate: NSObjectProtocol {
    func gpsDataStartLoading()
    func gpsDataNotAvailable()
    @objc optional func changeLocationPermission()
    @objc optional func gpsHeadingForCompass(newHeading: CLLocationDirection)
}

open class MRGpsDataGetter: NSObject, CLLocationManagerDelegate {
    
    public static let shared = MRGpsDataGetter()
    open weak var delegate : MRGpsDataGetterDelegate?
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var timerAutoRefreshSunMoon = Timer()
    var timerAutoRefreshWeather = Timer()
    var count = 0
//    var errorCount = 0
    var openWeatherMapKey = "NaN"
    var isHeadingAvailableOnDevice = false
    var isForecastToLoad = true
    var isLocationDataToLoadOnly = false
    
    
    open func initialize(timeOut: TimeInterval = 15.0){
        setAlamofire(timeOut)
    }
    
    private func setOptions(openWeatherMapKey: String, preferences : [String : String], forecastToo: Bool, onlyLocationData: Bool){
        setOpenWeatherMapKey(openWeatherMapKey)
        Preferences.shared.setPreferences(preferences)
        isForecastToLoad = forecastToo
        isLocationDataToLoadOnly = onlyLocationData
    }
    
    open func refreshAllData(openWeatherMapKey: String, preferences: [String : String], forecastMustBeLoaded: Bool = true, isLocationDataToLoadOnly: Bool = false){
        setCount(0)
        setLocationPermission(openWeatherMapKey: openWeatherMapKey, preferences: preferences, forecastMustBeLoaded: forecastMustBeLoaded, isLocationDataToLoadOnly: isLocationDataToLoadOnly)
    }
        
    open func setLocationPermission(openWeatherMapKey: String, preferences: [String : String], forecastMustBeLoaded: Bool = true, isLocationDataToLoadOnly: Bool = false){
        setOptions(openWeatherMapKey: openWeatherMapKey, preferences: preferences, forecastToo: forecastMustBeLoaded, onlyLocationData: isLocationDataToLoadOnly)
        DispatchQueue.global().async {
            self.locationManager.delegate = self
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    self.locationManager.requestWhenInUseAuthorization()
                    self.setLocationPermission(openWeatherMapKey: openWeatherMapKey, preferences: preferences, forecastMustBeLoaded: self.isForecastToLoad, isLocationDataToLoadOnly: self.isLocationDataToLoadOnly)
                    break
                case .restricted, .denied:
                    DispatchQueue.main.async {
                        self.delegate?.gpsDataStartLoading()
                        self.delegate?.gpsDataNotAvailable()
                    }
                    self.locationManager.delegate = nil
                    self.locationManager.stopUpdatingHeading()
                    self.locationManager.stopUpdatingLocation()
                    self.timerAutoRefreshSunMoon.invalidate()
                    self.timerAutoRefreshWeather.invalidate()
                    self.isHeadingAvailableOnDevice = false
                    debugPrint("Location permits NOT obtained!")
                    break
                case .authorizedWhenInUse:
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    self.locationManager.startUpdatingLocation()
                    self.locationManager.startUpdatingHeading()
                    debugPrint("Permissions for location (only if in use) obtained!")
                    break
                case .authorizedAlways: break
                @unknown default: break
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = nil
        currentLocation = locations.last
        if let loc = self.currentLocation, count == 0 {
            debugPrint("Location data obtained!")
            //            errorCount = 0
            locationManager.stopUpdatingLocation()
            delegate?.gpsDataStartLoading()
            
            ///////////CORE///////////////
            //GPS info thread
            DispatchQueue.global().async {
                GpsDataGetter.shared.getPositionInfo(currentLocation: loc)
            }
            //Location name thread
            DispatchQueue.global().async {
                GpsDataGetter.shared.getGeocodeFromLocation(currentLocation: loc)
            }
            if !self.isLocationDataToLoadOnly {
                //Sun info thread
                DispatchQueue.global().async {
                    SunDataGetter.shared.getSunInfo(currentLocation: loc)
                }
                //Moon info thread
                DispatchQueue.global().async {
                    MoonDataGetter.shared.getMoonInfo(currentLocation: loc)
                }
                if let b = Preferences.shared.getPreference("autoRefreshSunMoonInfo").bool, let d = Preferences.shared.getPreference("sunMoonRefreshSeconds").double(), b {
                    timerAutoRefreshSunMoon.invalidate()
                    timerAutoRefreshSunMoon = Timer.scheduledTimer(timeInterval: d, target: self, selector: #selector(self.refreshSunMoonPositionInfo), userInfo: nil, repeats: true)
                } else {
                    timerAutoRefreshSunMoon.invalidate()
                }
                

                //Weather info thread
                DispatchQueue.global().async {
                    WeatherDataGetter.shared.getWeatherInfo(openWeatherMapKey: self.openWeatherMapKey, currentLocation: loc)
                }
                //Forecast info thread
                DispatchQueue.global().async {
                    if self.isForecastToLoad {
                        ForecastDataGetter.shared.getForecastInfo(openWeatherMapKey: self.openWeatherMapKey, currentLocation: loc)
                    }
                }
                if let b = Preferences.shared.getPreference("autoRefreshWeatherInfo").bool, let d = Preferences.shared.getPreference("weatherRefreshSeconds").double(), b {
                    timerAutoRefreshWeather.invalidate()
                    timerAutoRefreshWeather = Timer.scheduledTimer(timeInterval: d, target: self, selector: #selector(self.refreshWeatherPositionInfo), userInfo: nil, repeats: true)
                } else {
                    timerAutoRefreshWeather.invalidate()
                }
            }
            //////////////////////////////


//        } else {
//            if errorCount > 0 {
//                return
//            }
//            debugPrint("Location data NOT obtained!")
//            locationManager.stopUpdatingLocation()
//            delegate?.gpsDataStartLoading()
//            delegate?.gpsDataNotAvailable()
//            errorCount = errorCount + 1
        }
        count = count + 1
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        debugPrint(error.localizedDescription)
//          delegate?.gpsDataNotAvailable()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.changeLocationPermission?()
//        refreshAllData(openWeatherMapKey: openWeatherMapKey, preferences: preferences)
    }
    
    @objc private func refreshSunMoonPositionInfo(){
        if let loc = currentLocation, count > 0 {
            DispatchQueue.global().async {
                GpsDataGetter.shared.getPositionInfo(currentLocation: loc)
            }
            DispatchQueue.global().async {
                SunDataGetter.shared.getSunInfo(currentLocation: loc)
            }
            DispatchQueue.global().async {
                MoonDataGetter.shared.getMoonInfo(currentLocation: loc)
            }
        }
    }

    @objc private func refreshWeatherPositionInfo(){
        if let loc = currentLocation, count > 0 {
            DispatchQueue.global().async {
                WeatherDataGetter.shared.getWeatherInfo(openWeatherMapKey: self.openWeatherMapKey, currentLocation: loc)
            }
            DispatchQueue.global().async {
                if self.isForecastToLoad {
                    ForecastDataGetter.shared.getForecastInfo(openWeatherMapKey: self.openWeatherMapKey, currentLocation: loc)
                }
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        isHeadingAvailableOnDevice = true
        if let b = Preferences.shared.getPreference("trueNorth").bool, b {
            delegate?.gpsHeadingForCompass?(newHeading: newHeading.trueHeading)
        } else {
            delegate?.gpsHeadingForCompass?(newHeading: newHeading.magneticHeading)
        }
    }
    
    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return false
    }
    
    open func isHeadingAvailable() -> Bool {
        return isHeadingAvailableOnDevice
    }
    
    open func startHeading() {
        locationManager.startUpdatingHeading()
    }
    
    open func stopHeading() {
        locationManager.stopUpdatingHeading()
    }
    
    open func setCurrentLocation(_ currentLocation: CLLocation) {
        return self.currentLocation = currentLocation
    }
    
    open func getCurrentLocation() -> CLLocation? {
        return currentLocation
    }
    
    //MARK: - Support functions for gps
    private func setCount(_ value: Int) {
        count = value
//        errorCount = value
    }
    
    private func setOpenWeatherMapKey(_ openWeatherMapKey: String){
        if self.openWeatherMapKey == "NaN" {
            self.openWeatherMapKey = openWeatherMapKey
        }
    }

}
