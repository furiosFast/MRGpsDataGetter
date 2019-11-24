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

@objc public protocol MRGpsDataGetterWeatherDataDelegate: NSObjectProtocol {
    func weatherDataReady(weather: GpsWeatherModel)
    @objc optional func weatherDataNotAvaiable(error: String)
}

open class WeatherDataGetter: NSObject {
        
    public static let shared = WeatherDataGetter()
    open weak var delegate : MRGpsDataGetterWeatherDataDelegate?
    
    let weather = GpsWeatherModel()
    
    
    open func getWeatherInfo(openWeatherMapKey: String, currentLocation: CLLocation) {
        DispatchQueue.global().async {
            self.getWeatherInfoFromWeb(openWeatherMapKey, currentLocation)
        }
    }
    
    private func getWeatherInfoFromWeb(_ openWeatherMapKey: String, _ currentLocation: CLLocation) {
        if openWeatherMapKey == "NaN" {
            self.delegate?.weatherDataNotAvaiable?(error: "openWeatherMapKey is NaN")
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
        print("Weather openweathermap API ENDPOINT iOS " + urlString)
        
        AFManager.request(urlString, parameters: parameters).responseJSON { response in
            if let er = response.error {
                self.delegate?.weatherDataNotAvaiable?(error: er.localizedDescription)
                return
            }
            guard let ilJson = response.value else {
                print("JSON Nil")
                self.delegate?.weatherDataNotAvaiable?(error: "JSON is nil")
                return
            }
            let json = JSON(ilJson)
            if let openWeatherMapError = (json["cod"].stringValue).int {
                if (openWeatherMapError != 200) {
                    self.delegate?.weatherDataNotAvaiable?(error: "OpenWeatherMap.org error: " + openWeatherMapError.string)
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
            if let velVento = json["wind"]["speed"].stringValue.double() {
                if Preferences.shared.getPreference("windSpeed") == "meterSecondSpeed" {
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        self.weather.windSpeed = (velVento * milesHourToMeterSecond).string
                        self.weather.beaufortScale = getBeaufortForce(velVento * milesHourToKnot)
                    } else {
                        self.weather.windSpeed = velVento.string
                        self.weather.beaufortScale = getBeaufortForce(velVento * meterSecondToKnot)
                    }
                }
                if Preferences.shared.getPreference("windSpeed") == "kilometerHoursSpeed" {
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        self.weather.windSpeed = (velVento * milesHourToKilometerHour).string
                        self.weather.beaufortScale = getBeaufortForce(velVento * milesHourToKnot)
                    } else {
                        self.weather.windSpeed = (velVento * meterSecondToKilometerHour).string
                        self.weather.beaufortScale = getBeaufortForce(velVento * meterSecondToKnot)
                    }
                }
                if Preferences.shared.getPreference("windSpeed") == "knotSpeed" {
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        self.weather.windSpeed = (velVento * milesHourToKnot).string
                        self.weather.beaufortScale = getBeaufortForce(velVento * milesHourToKnot)
                    } else {
                        self.weather.windSpeed = (velVento * meterSecondToKnot).string
                        self.weather.beaufortScale = getBeaufortForce(velVento * meterSecondToKnot)
                    }
                }
                if Preferences.shared.getPreference("windSpeed") == "milesHoursSpeed" {
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        self.weather.windSpeed = velVento.string
                        self.weather.beaufortScale = getBeaufortForce(velVento * milesHourToKnot)
                    } else {
                        self.weather.windSpeed = (velVento * meterSecondToMilesHour).string
                        self.weather.beaufortScale = getBeaufortForce(velVento * meterSecondToKnot)
                    }
                }
                if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                    self.weather.beaufortScaleWindColour = getBeaufortForceColor(velVento * milesHourToKnot)
                } else {
                    self.weather.beaufortScaleWindColour = getBeaufortForceColor(velVento * meterSecondToKnot)
                }
            }
            //6-7-8
            if let angVento = json["wind"]["deg"].stringValue.double() {
                self.weather.windDegree = String(format: "%3.1f", angVento)
                self.weather.windName = getWindName(angVento)
            }
            //9
            if let rain = json["rain"]["1h"].stringValue.double() {
                self.weather.rain1h = String(format: "%3.1f", rain) + " " + loc("MILLIMETERS")
            } else {
                self.weather.rain1h = "0.0 " + loc("MILLIMETERS")
            }
            //10
            if let rain = json["rain"]["3h"].stringValue.double() {
                self.weather.rain3h = String(format: "%3.1f", rain) + " " + loc("MILLIMETERS")
            } else {
                self.weather.rain3h = "0.0 " + loc("MILLIMETERS")
            }
            //11
            if let vis = json["visibility"].stringValue.double() {
                self.weather.visibility = String(format: "%3.1f", vis/1000) + " " + loc("KILOMETERS")
            }
            //12
            if let pres = json["main"]["pressure"].stringValue.double() {
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
            if let pres = json["main"]["sea_level"].stringValue.double() {
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
            if let pres = json["main"]["grnd_level"].stringValue.double() {
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
            if let hum = json["main"]["humidity"].stringValue.double() {
                self.weather.umidity = hum.string + " " + loc("PERCENT")
            }
            //16
            if let temp = json["main"]["temp"].stringValue.double() {
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
            if let tempMin = json["main"]["temp_min"].stringValue.double() {
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
            if let tempMax = json["main"]["temp_max"].stringValue.double() {
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
            if let snow = json["snow"]["1h"].stringValue.double() {
                self.weather.snow1h = String(format: "%3.1f", snow) + " " + loc("MILLIMETERS")
            } else {
                self.weather.snow1h = "0.0 " + loc("MILLIMETERS")
            }
            //20
            if let snow = json["snow"]["3h"].stringValue.double() {
                self.weather.snow3h = String(format: "%3.1f", snow) + " " + loc("MILLIMETERS")
            } else {
                self.weather.snow3h = "0.0 " + loc("MILLIMETERS")
            }
            //21
            if let clouds = json["clouds"]["all"].stringValue.double() {
                self.weather.clouds = clouds.string + " " + loc("PERCENT")
            }
            
            self.delegate?.weatherDataReady(weather: self.weather)
        }
    }
    
    open func getOldWeatherData() -> GpsWeatherModel {
        return weather
    }
    
}
