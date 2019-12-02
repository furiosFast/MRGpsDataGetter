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
    var timerAutoRefresh = Timer()
    var count = 0
//    var errorCount = 0
    var openWeatherMapKey = "NaN"
    var isHeadingAvailableOnDevice = false
    var isForecastToLoad = true

    
    open func initialize(_ timeOut: TimeInterval = 15.0){
        setAlamofire(timeOut)
    }
    
    open func refreshAllData(openWeatherMapKey: String, preferences: [String : String], forecastMustBeLoaded: Bool = true){
        setCount(0)
        setLocationPermission(openWeatherMapKey: openWeatherMapKey, preferences: preferences, forecastMustBeLoaded: forecastMustBeLoaded)
    }
        
    open func setLocationPermission(openWeatherMapKey: String, preferences : [String : String], forecastMustBeLoaded: Bool = true){
        setOptions(openWeatherMapKey, preferences, forecastMustBeLoaded)
        DispatchQueue.global().async {
            self.locationManager.delegate = self
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    self.locationManager.requestWhenInUseAuthorization()
                    self.setLocationPermission(openWeatherMapKey: openWeatherMapKey, preferences: preferences, forecastMustBeLoaded: self.isForecastToLoad)
                    break
                case .restricted, .denied:
                    DispatchQueue.main.async {
                        self.delegate?.gpsDataStartLoading()
                        self.delegate?.gpsDataNotAvailable()
                    }
                    self.locationManager.delegate = nil
                    self.locationManager.stopUpdatingHeading()
                    self.locationManager.stopUpdatingLocation()
                    self.timerAutoRefresh.invalidate()
                    self.isHeadingAvailableOnDevice = false
                    print("Permessi per localizzazzione negati!")
                    break
                case .authorizedWhenInUse:
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    self.locationManager.startUpdatingLocation()
                    self.locationManager.startUpdatingHeading()
                    print("Permessi per localizzazzione (solo se in uso) ottenuti!")
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
            print("Dati sulla localizzazione ottenuti")
//            errorCount = 0
            locationManager.stopUpdatingLocation()
            delegate?.gpsDataStartLoading()

            WeatherDataGetter.shared.getWeatherInfo(openWeatherMapKey: openWeatherMapKey, currentLocation: loc)
            if isForecastToLoad {
                ForecastDataGetter.shared.getForecastInfo(openWeatherMapKey: openWeatherMapKey, currentLocation: loc)
            }
            GpsDataGetter.shared.getPositionInfo(currentLocation: loc)
            SunDataGetter.shared.getSunInfo(currentLocation: loc)
            MoonDataGetter.shared.getMoonInfo(currentLocation: loc)
            
            if let b = Bool(Preferences.shared.getPreference("autoRefreshSunMoonInfo")), b == true {
                timerAutoRefresh.invalidate()
                    timerAutoRefresh = Timer.scheduledTimer(timeInterval: Double(Preferences.shared.getPreference("sunMoonRefreshSeconds"))!, target: self, selector: #selector(self.autoRefreshSunMoonInfo), userInfo: nil, repeats: true)
            } else {
                timerAutoRefresh.invalidate()
            }
//        } else {
//            if errorCount > 0 {
//                return
//            }
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
    
    @objc private func autoRefreshSunMoonInfo(){
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
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        isHeadingAvailableOnDevice = true
        if Bool(Preferences.shared.getPreference("trueNorth"))! == true {
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
    
    private func setOptions(_ openWeatherMapKey: String, _ preferences : [String : String], _ forecastToo: Bool){
        setOpenWeatherMapKey(openWeatherMapKey)
        Preferences.shared.setPreferences(preferences)
        isForecastToLoad = forecastToo
    }
    
    private func setOpenWeatherMapKey(_ openWeatherMapKey: String){
        if self.openWeatherMapKey == "NaN" {
            self.openWeatherMapKey = openWeatherMapKey
        }
    }

}
