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

public protocol MRGpsDataGetterStarterDelegate: NSObjectProtocol {
    func gpsDataStartLoading()
    func gpsDataNotAvaiable()
    func setGpsMap(currentLocation: CLLocation)
    func gpsHeadingForCompass(newHeading: CLHeading)
}

open class DataGetterStarter: NSObject, CLLocationManagerDelegate {
    
    public static let shared = DataGetterStarter()
    
    open weak var delegate : MRGpsDataGetterStarterDelegate?
    lazy var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapLocation: CLLocationCoordinate2D?
    var timerAutoRefresh = Timer()
    var count = 0
    var loadForecastAndWeatherInfoFromOpenWeatherMapController: Bool = false
    var openWeatherMapKey = "NaN"
    
    
    open func refreshAllWeatherData(){
        setCount(0)
        setLocationPermission(openWeatherMapKey: openWeatherMapKey, preferences: Preferences.shared.prefs)
    }
        
    open func setLocationPermission(openWeatherMapKey: String, preferences : [String : String]){
        setOptions(openWeatherMapKey, preferences)
        DispatchQueue.global().async {
            self.locationManager.delegate = self
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    self.locationManager.requestWhenInUseAuthorization()
                    self.setLocationPermission(openWeatherMapKey: openWeatherMapKey, preferences: preferences)
                    break
                case .restricted, .denied:
                    DispatchQueue.main.async {
                        self.delegate?.gpsDataStartLoading()
                        self.delegate?.gpsDataNotAvaiable()
                    }
                    self.locationManager.delegate = nil
                    self.locationManager.stopUpdatingHeading()
                    self.locationManager.stopUpdatingLocation()
                    self.timerAutoRefresh.invalidate()
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
            locationManager.stopUpdatingLocation()
            self.delegate?.gpsDataStartLoading()

//            GpsDataGetter().reverseGeocodeLocation(loc)
//            WeatherDataGetter().getWeatherInfo(openWeatherMapKey: openWeatherMapKey, currentLocation: loc)
//            self.delegate?.setGpsMap(loc)
//            GpsDataGetter().getPositionInfo(currentLocation: loc)
            SunDataGetter().getSunInfo(currentLocation: loc)
//            MoonDataGetter().getMoonInfo(currentLocation: loc)
            
            
            if let b = Bool(Preferences.shared.getPreference("autoRefreshSunMoonInfo")), b == true {
                timerAutoRefresh.invalidate()
                timerAutoRefresh = Timer.scheduledTimer(timeInterval: Double(Preferences.shared.getPreference("sunMoonRefreshSeconds"))!, target: self, selector: #selector(self.autoRefreshSunMoonInfo), userInfo: nil, repeats: true)
            } else {
                timerAutoRefresh.invalidate()
            }
            
            
            DispatchQueue.global().async {
                if self.loadForecastAndWeatherInfoFromOpenWeatherMapController {
                    ForecastDataGetter().getForecastInfo(openWeatherMapKey: self.openWeatherMapKey, currentLocation: loc)
                    self.loadForecastAndWeatherInfoFromOpenWeatherMapController = false
                }
            }
        }
        count = count + 1
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        //print(error.localizedDescription)
        //setNotAvaiablePositionInfo()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //non serve poichè avendo il metodo deinit effettua l'aggiornamento dei dati, in caso di cambio impostazioni fa già lui il refresh dell'ui
        //setLocationPermission()
    }
    
    @objc private func autoRefreshSunMoonInfo(){
        if let loc = currentLocation, count > 0 {
            DispatchQueue.global().async {
                GpsDataGetter().getPositionInfo(currentLocation: loc)
            }
            DispatchQueue.global().async {
                SunDataGetter().getSunInfo(currentLocation: loc)
            }
            DispatchQueue.global().async {
                MoonDataGetter().getMoonInfo(currentLocation: loc)
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.delegate?.gpsHeadingForCompass(newHeading: newHeading)
    }
    
    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    open func startHeading(){
        self.locationManager.startUpdatingHeading()
    }
    
    open func stopHeading(){
        self.locationManager.stopUpdatingHeading()
    }
    
    //MARK: - Support functions for gps
    private func setCount(_ value:Int) {
        count = value
    }
    
    private func setOptions(_ openWeatherMapKey: String, _ preferences : [String : String]){
        setOpenWeatherMapKey(openWeatherMapKey)
        Preferences.shared.setPreferences(preferences)
    }
    
    private func setOpenWeatherMapKey(_ openWeatherMapKey: String){
        if self.openWeatherMapKey == "NaN" {
            self.openWeatherMapKey = openWeatherMapKey
        }
    }
    
}
