//
//  MRGpsDataGetter.swift
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

import CoreLocation
import UIKit
import WeatherKit

@objc public protocol MRGpsDataGetterDelegate: NSObjectProtocol {
    func gpsDataStartLoading()
    func gpsDataNotAvailable()
    @objc optional func changeLocationPermission()
    @objc optional func gpsHeadingForCompass(newHeading: CLLocationDirection)
}

open class MRGpsDataGetter: NSObject, CLLocationManagerDelegate {
    public static var shared = MRGpsDataGetter()
    open weak var delegate: MRGpsDataGetterDelegate?

    public let gpsDataGetter = GpsDataGetter()
    public let sunDataGetter = SunDataGetter()
    public let moonDataGetter = MoonDataGetter()
    public let weatherDataGetter = WeatherDataGetter()
    public let forecastDataGetter = ForecastDataGetter()

    public var preferences = MRGpsPreferences()

    var locationManager: CLLocationManager = .init()
    var currentLocation: CLLocation?
    var timerAutoRefreshSunMoon = Timer()
    var count = 0
    var isForecastToLoad = true
    var isLocationDataToLoadOnly = false

    open func refreshAllData(forecastMustBeLoaded: Bool = true, isLocationDataToLoadOnly: Bool = false) {
        setCount(0)
        isForecastToLoad = forecastMustBeLoaded
        self.isLocationDataToLoadOnly = isLocationDataToLoadOnly
        startLocationUpdates()
    }

    private func startLocationUpdates() {
        DispatchQueue.main.async {
            self.delegate?.gpsDataStartLoading()
        }
        DispatchQueue.global().async {
            self.locationManager.delegate = self
            switch self.locationManager.authorizationStatus {
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
                self.startLocationUpdates()
            case .restricted, .denied:
                DispatchQueue.main.async {
                    self.delegate?.gpsDataStartLoading()
                    self.delegate?.gpsDataNotAvailable()
                }
                self.locationManager.delegate = nil
                self.locationManager.stopUpdatingHeading()
                self.locationManager.stopUpdatingLocation()
                self.timerAutoRefreshSunMoon.invalidate()
                debugPrint("Location permits NOT obtained!")
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.startUpdatingLocation()
                self.locationManager.startUpdatingHeading()
                debugPrint("Permissions for location obtained!")
            @unknown default: break
            }
        }
    }

    public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = nil
        currentLocation = locations.last
        if let loc = currentLocation, count == 0 {
            debugPrint("Location data obtained!")
            locationManager.stopUpdatingLocation()

            Task.detached { [weak self] in
                self?.gpsDataGetter.getPositionInfo(currentLocation: loc)
            }
            Task.detached { [weak self] in
                self?.gpsDataGetter.getGeocodeFromLocation(currentLocation: loc)
            }

            if !isLocationDataToLoadOnly {
                Task.detached { [weak self] in
                    self?.sunDataGetter.getSunInfo(currentLocation: loc)
                }
                Task.detached { [weak self] in
                    self?.moonDataGetter.getMoonInfo(currentLocation: loc)
                }

                if preferences.autoRefreshSunMoon {
                    timerAutoRefreshSunMoon.invalidate()
                    timerAutoRefreshSunMoon = Timer.scheduledTimer(timeInterval: preferences.sunMoonRefreshInterval, target: self, selector: #selector(refreshSunMoonPositionInfo), userInfo: nil, repeats: true)
                } else {
                    timerAutoRefreshSunMoon.invalidate()
                }

                weatherDataGetter.getWeatherInfo(currentLocation: loc)
                if isForecastToLoad {
                    forecastDataGetter.getForecastInfo(currentLocation: loc)
                }
            }
        }
        count = count + 1
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Swift.Error) {
        debugPrint(error.localizedDescription)
    }

    public func locationManager(_: CLLocationManager, didChangeAuthorization _: CLAuthorizationStatus) {
        delegate?.changeLocationPermission?()
    }

    public func locationManager(_: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if preferences.useTrueNorth {
            delegate?.gpsHeadingForCompass?(newHeading: newHeading.trueHeading)
        } else {
            delegate?.gpsHeadingForCompass?(newHeading: newHeading.magneticHeading)
        }
    }

    public func locationManagerShouldDisplayHeadingCalibration(_: CLLocationManager) -> Bool {
        return false
    }

    open func isHeadingAvailable() -> Bool {
        return CLLocationManager.headingAvailable()
    }

    open func startHeading() {
        locationManager.startUpdatingHeading()
    }

    open func stopHeading() {
        locationManager.stopUpdatingHeading()
    }

    open func setCurrentLocation(_ currentLocation: CLLocation) {
        self.currentLocation = currentLocation
    }

    open func getCurrentLocation() -> CLLocation? {
        return currentLocation
    }

    // MARK: - Support functions

    private func setCount(_ value: Int) {
        count = value
    }

    @objc private func refreshSunMoonPositionInfo() {
        if let loc = currentLocation, count > 0 {
            Task.detached { [weak self] in
                self?.gpsDataGetter.getPositionInfo(currentLocation: loc)
            }
            Task.detached { [weak self] in
                self?.sunDataGetter.getSunInfo(currentLocation: loc)
            }
            Task.detached { [weak self] in
                self?.moonDataGetter.getMoonInfo(currentLocation: loc)
            }
        }
    }

    open func getGpsDataGetter() -> GpsDataGetter {
        return gpsDataGetter
    }

    open func getSunDataGetter() -> SunDataGetter {
        return sunDataGetter
    }

    open func getMoonDataGetter() -> MoonDataGetter {
        return moonDataGetter
    }

    open func getWeatherDataGetter() -> WeatherDataGetter {
        return weatherDataGetter
    }

    open func getForecastDataGetter() -> ForecastDataGetter {
        return forecastDataGetter
    }

    // MARK: - Weather Attribution

    open func getWeatherAttribution() async throws -> WeatherAttribution {
        return try await WeatherService.shared.attribution
    }
}
