//
//  WeatherDataGetter.swift
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
import Alamofire
import SwiftyJSON
import SwifterSwift

@objc public protocol MRGpsDataGetterWeatherDataDelegate: NSObjectProtocol {
    func weatherDataReady(weather: GpsWeatherModel)
    @objc optional func weatherDataNotAvailable(error: String)
}

open class WeatherDataGetter: NSObject {
        
    public static let shared = WeatherDataGetter()
    open weak var delegate : MRGpsDataGetterWeatherDataDelegate?
    
    let weather = GpsWeatherModel()
    
    
    /// Function that start to retrive current Weather (provider: OpenWeatherMap.org) data based on a specified location
    /// - Parameters:
    ///   - openWeatherMapKey: OpenWeatherMapKey.org key
    ///   - currentLocation: location
    open func getWeatherInfo(openWeatherMapKey: String, currentLocation: CLLocation) {
        DispatchQueue.global().async {
            self.getWeatherInfoFromWeb(openWeatherMapKey, currentLocation)
        }
    }
    
    /// Private function that start to retrive current Weather (provider: OpenWeatherMap.org) data based on a specified location
    /// - Parameters:
    ///   - openWeatherMapKey: OpenWeatherMapKey.org key
    ///   - currentLocation: location
    private func getWeatherInfoFromWeb(_ openWeatherMapKey: String, _ currentLocation: CLLocation) {
        if openWeatherMapKey == "NaN" {
            self.delegate?.weatherDataNotAvailable?(error: "openWeatherMapKey is NaN")
        }
        
        var units = ""
        switch Preferences.shared.getPreference("weatherTemp") {
            case "celsusTemp": units = loc("UNITSMETRIC")
            case "fahrenheitTemp": units = loc("UNITSIMPERIAL")
            case "kelvinTemp": units = ""
            default: units = ""
        }
        
        let urlString = "http://api.openweathermap.org/data/2.5/weather"
        let parameters: Dictionary = [
            "lat"           : currentLocation.coordinate.latitude.string,
            "lon"           : currentLocation.coordinate.longitude.string,
            "type"          : "accurate",
            "units"         : units,
            "lang"          : loc("LANG"),
            "appid"         : openWeatherMapKey
        ]
        debugPrint("Weather openweathermap API ENDPOINT iOS " + urlString)
        
        AFManager.request(urlString, parameters: parameters).responseJSON { response in
            if let er = response.error {
                self.delegate?.weatherDataNotAvailable?(error: er.localizedDescription)
                return
            }
            guard let ilJson = response.value else {
                self.delegate?.weatherDataNotAvailable?(error: "JSON is nil")
                return
            }
            let json = JSON(ilJson)
            if let openWeatherMapError = (json["cod"].stringValue).int {
                if (openWeatherMapError != 200) {
                    self.delegate?.weatherDataNotAvailable?(error: "OpenWeatherMap.org error: " + openWeatherMapError.string)
                    return
                }
            }
            
            //0
            self.weather.currentLocation = currentLocation
            //1
            if let weatherDescr = json["weather"][0]["description"].string {
                self.weather.weatherDescription = weatherDescr
            }
            //2
            if let weatherIcon = json["weather"][0]["icon"].string {
                self.weather.weatherOpenWeatherMapIcon = weatherIcon
            }
            //3-4-5
            if let windSpeed = Double(json["wind"]["speed"].stringValue) {
                if Preferences.shared.getPreference("windSpeed") == "meterSecondSpeed" {
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        self.weather.windSpeed = (windSpeed * milesHourToMeterSecond).string
                        self.weather.beaufortScale = getBeaufortForce(windSpeed * milesHourToKnot)
                    } else {
                        self.weather.windSpeed = windSpeed.string
                        self.weather.beaufortScale = getBeaufortForce(windSpeed * meterSecondToKnot)
                    }
                }
                if Preferences.shared.getPreference("windSpeed") == "kilometerHoursSpeed" {
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        self.weather.windSpeed = (windSpeed * milesHourToKilometerHour).string
                        self.weather.beaufortScale = getBeaufortForce(windSpeed * milesHourToKnot)
                    } else {
                        self.weather.windSpeed = (windSpeed * meterSecondToKilometerHour).string
                        self.weather.beaufortScale = getBeaufortForce(windSpeed * meterSecondToKnot)
                    }
                }
                if Preferences.shared.getPreference("windSpeed") == "knotSpeed" {
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        self.weather.windSpeed = (windSpeed * milesHourToKnot).string
                        self.weather.beaufortScale = getBeaufortForce(windSpeed * milesHourToKnot)
                    } else {
                        self.weather.windSpeed = (windSpeed * meterSecondToKnot).string
                        self.weather.beaufortScale = getBeaufortForce(windSpeed * meterSecondToKnot)
                    }
                }
                if Preferences.shared.getPreference("windSpeed") == "milesHoursSpeed" {
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        self.weather.windSpeed = windSpeed.string
                        self.weather.beaufortScale = getBeaufortForce(windSpeed * milesHourToKnot)
                    } else {
                        self.weather.windSpeed = (windSpeed * meterSecondToMilesHour).string
                        self.weather.beaufortScale = getBeaufortForce(windSpeed * meterSecondToKnot)
                    }
                }
                if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                    self.weather.beaufortScaleWindColour = getBeaufortForceColor(windSpeed * milesHourToKnot)
                } else {
                    self.weather.beaufortScaleWindColour = getBeaufortForceColor(windSpeed * meterSecondToKnot)
                }
            }
            //6-7-8
            if let windAngle = Double(json["wind"]["deg"].stringValue) {
                self.weather.windDegree = String(format: "%3.1f", windAngle)
                self.weather.windName = getWindName(windAngle)
            }
            //9
            if let rain = Double(json["rain"]["1h"].stringValue) {
                self.weather.rain1h = String(format: "%3.1f", rain) + " " + loc("MILLIMETERS")
            } else {
                self.weather.rain1h = "0.0 " + loc("MILLIMETERS")
            }
            //10
            if let rain = Double(json["rain"]["3h"].stringValue) {
                self.weather.rain3h = String(format: "%3.1f", rain) + " " + loc("MILLIMETERS")
            } else {
                self.weather.rain3h = "0.0 " + loc("MILLIMETERS")
            }
            //11
            if let vis = Double(json["visibility"].stringValue) {
                self.weather.visibility = String(format: "%3.1f", vis/1000) + " " + loc("KILOMETERS")
            }
            //12
            if let pres = Double(json["main"]["pressure"].stringValue) {
                if Preferences.shared.getPreference("pressureUnit") == "atm" {
                    self.weather.pressure = String(format: "%3.3f", pres * hpaToAtm) + " " + loc("ATM")
                }
                if Preferences.shared.getPreference("pressureUnit") == "bar" {
                    self.weather.pressure = String(format: "%3.3f", pres * hpaToBar) + " " + loc("BAR")
                }
                if Preferences.shared.getPreference("pressureUnit") == "hPa" {
                    self.weather.pressure = String(format: "%3.1f", pres) + " " + loc("HPA")
                }
            }
            //13
            if let pres = Double(json["main"]["sea_level"].stringValue) {
                if Preferences.shared.getPreference("pressureUnit") == "atm" {
                    self.weather.pressureSeaLevel = String(format: "%3.3f", pres * hpaToAtm) + " " + loc("ATM")
                }
                if Preferences.shared.getPreference("pressureUnit") == "bar" {
                    self.weather.pressureSeaLevel = String(format: "%3.3f", pres * hpaToBar) + " " + loc("BAR")
                }
                if Preferences.shared.getPreference("pressureUnit") == "hPa" {
                    self.weather.pressureSeaLevel = String(format: "%3.1f", pres) + " " + loc("HPA")
                }
            }
            //14
            if let pres = Double(json["main"]["grnd_level"].stringValue) {
                if Preferences.shared.getPreference("pressureUnit") == "atm" {
                    self.weather.pressureGroundLevel = String(format: "%3.3f", pres * hpaToAtm) + " " + loc("ATM")
                }
                if Preferences.shared.getPreference("pressureUnit") == "bar" {
                    self.weather.pressureGroundLevel = String(format: "%3.3f", pres * hpaToBar) + " " + loc("BAR")
                }
                if Preferences.shared.getPreference("pressureUnit") == "hPa" {
                    self.weather.pressureGroundLevel = String(format: "%3.1f", pres) + " " + loc("HPA")
                }
            } else {
                self.weather.pressureGroundLevel = self.weather.pressure
            }
            //15
            if let hum = Double(json["main"]["humidity"].stringValue) {
                self.weather.umidity = hum.string + " " + loc("PERCENT")
            }
            //16
            if let temp = Double(json["main"]["temp"].stringValue) {
                if Preferences.shared.getPreference("weatherTemp") == "celsusTemp" {
                    self.weather.temp = String(format: "%3.1f", temp) + " " + loc("CELSUS")
                }
                if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                    self.weather.temp = String(format: "%3.1f", temp) + " " + loc("FAHRENHEIT")
                }
                if Preferences.shared.getPreference("weatherTemp") == "kelvinTemp" {
                    self.weather.temp = String(format: "%3.1f", temp) + " " + loc("KELVIN")
                }
            }
            //17
            if let tempMin = Double(json["main"]["temp_min"].stringValue) {
                if Preferences.shared.getPreference("weatherTemp") == "celsusTemp" {
                    self.weather.tempMin = String(format: "%3.1f", tempMin) + " " + loc("CELSUS")
                }
                if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                    self.weather.tempMin = String(format: "%3.1f", tempMin) + " " + loc("FAHRENHEIT")
                }
                if Preferences.shared.getPreference("weatherTemp") == "kelvinTemp" {
                    self.weather.tempMin = String(format: "%3.1f", tempMin) + " " + loc("KELVIN")
                }
            }
            //18
            if let tempMax = Double(json["main"]["temp_max"].stringValue) {
                if Preferences.shared.getPreference("weatherTemp") == "celsusTemp" {
                    self.weather.tempMax = String(format: "%3.1f", tempMax) + " " + loc("CELSUS")
                }
                if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                    self.weather.tempMax = String(format: "%3.1f", tempMax) + " " + loc("FAHRENHEIT")
                }
                if Preferences.shared.getPreference("weatherTemp") == "kelvinTemp" {
                    self.weather.tempMax = String(format: "%3.1f", tempMax) + " " + loc("KELVIN")
                }
            }
            //19
            if let snow = Double(json["snow"]["1h"].stringValue) {
                self.weather.snow1h = String(format: "%3.1f", snow) + " " + loc("MILLIMETERS")
            } else {
                self.weather.snow1h = "0.0 " + loc("MILLIMETERS")
            }
            //20
            if let snow = Double(json["snow"]["3h"].stringValue) {
                self.weather.snow3h = String(format: "%3.1f", snow) + " " + loc("MILLIMETERS")
            } else {
                self.weather.snow3h = "0.0 " + loc("MILLIMETERS")
            }
            //21
            if let clouds = Double(json["clouds"]["all"].stringValue) {
                self.weather.clouds = clouds.string + " " + loc("PERCENT")
            }
            
            DispatchQueue.main.async {
                self.delegate?.weatherDataReady(weather: self.weather)
            }
        }
    }
    
    /// Get the weather data object
    open func getOldWeatherData() -> GpsWeatherModel {
        return weather
    }
    
}
