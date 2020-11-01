//
//  ForecastDataGetter.swift
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

@objc public protocol MRGpsDataGetterForecastDataDelegate: NSObjectProtocol {
    func forecastDataReady(forecast: [WeatherModel])
    @objc optional func forecastDataNotAvailable(error: String)
}

open class ForecastDataGetter: NSObject {
    
    public static let shared = ForecastDataGetter()
    open weak var delegate : MRGpsDataGetterForecastDataDelegate?
    
    var forecast : [WeatherModel] = []
    var plotDataWindName: [String] = []
    var plotData: [Double] = []
    var plotDataTime: [String] = []
    
    
    /// Function that start to retrive the Forecast for the next 5 days (provider: OpenWeatherMap.org) data based on a specified location
    /// - Parameters:
    ///   - openWeatherMapKey: OpenWeatherMapKey.org key
    ///   - currentLocation: location
    open func getForecastInfo(openWeatherMapKey: String, currentLocation: CLLocation) {
        getForecastInfoFromWeb(openWeatherMapKey, currentLocation)
    }
    
    /// Private function that start to retrive the Forecast for the next 5 days (provider: OpenWeatherMap.org) data based on a specified location
    /// - Parameters:
    ///   - openWeatherMapKey: OpenWeatherMapKey.org key
    ///   - currentLocation: location
    private func getForecastInfoFromWeb(_ openWeatherMapKey: String, _ currentLocation: CLLocation) {
        if openWeatherMapKey == "NaN" {
            self.delegate?.forecastDataNotAvailable?(error: "openWeatherMapKey is NaN")
        }
        
        var units = ""
        switch Preferences.shared.getPreference("weatherTemp") {
            case "celsusTemp": units = loc("UNITSMETRIC")
            case "fahrenheitTemp": units = loc("UNITSIMPERIAL")
            case "kelvinTemp": units = ""
            default: units = ""
        }
        
        let urlString = "http://api.openweathermap.org/data/2.5/forecast"
        let parameters: Dictionary = [
            "lat"           : currentLocation.coordinate.latitude.string,
            "lon"           : currentLocation.coordinate.longitude.string,
            "type"          : "accurate",
            "units"         : units,
            "lang"          : loc("LANG"),
            "appid"         : openWeatherMapKey
        ]
        debugPrint("Forecast openweathermap API ENDPOINT iOS " + urlString)
        
        guard let url = URL(string: urlString) else { return }
        AFManager.request(url, parameters: parameters).responseJSON { response in
            if let er = response.error {
                self.delegate?.forecastDataNotAvailable?(error: er.localizedDescription)
                return
            }
            guard let ilJson = response.value else {
                self.delegate?.forecastDataNotAvailable?(error: "JSON Nil")
                return
            }
            let json = JSON(ilJson)
            if let openWeatherMapError = (json["cod"].stringValue).int {
                if (openWeatherMapError != 200) {
                    self.delegate?.forecastDataNotAvailable?(error: "openWeatherMap.org error: " + openWeatherMapError.string)
                    return
                }
            }
            
            self.forecast = []
            self.plotData = []
            self.plotDataTime = []
            self.plotDataWindName = []
            for i in 0..<json["list"].count {
                let weather = WeatherModel()
                
                //0
                weather.currentWeatherLocation = currentLocation
                //1
                if var weatherDescr = json["list"][i]["weather"][0]["description"].string {
                    weatherDescr.firstCharacterUppercased()
                    weather.weatherDescription = weatherDescr
                }
                //2
                if let weatherIcon = json["list"][i]["weather"][0]["icon"].string {
                    if let img = UIImage(named: weatherIcon, in: .module, with: nil) {
                        weather.weatherOpenWeatherMapIconName = weatherIcon
                        weather.weatherOpenWeatherMapIcon = img
                    } else {
                        weather.weatherOpenWeatherMapIconName = "01d"
                        weather.weatherOpenWeatherMapIcon = UIImage(named: "01d", in: .module, with: nil)!
                    }
                }
                //3-4-5-6
                //Wind speed. Unit Default: meter/sec, Metric: meter/sec, Imperial: miles/hour.
                if let windSpeed = Double(json["list"][i]["wind"]["speed"].stringValue) {
                    if Preferences.shared.getPreference("windSpeed") == "meterSecondSpeed" {
                        if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                            weather.windSpeed = (windSpeed * milesHourToMeterSecond).string
                            weather.beaufortScale = getBeaufortForce(windSpeed * milesHourToKnot)
                            self.plotData.append(windSpeed * milesHourToMeterSecond)
                        } else {
                            weather.windSpeed = windSpeed.string
                            weather.beaufortScale = getBeaufortForce(windSpeed * meterSecondToKnot)
                            self.plotData.append(windSpeed)
                        }
                    }
                    if Preferences.shared.getPreference("windSpeed") == "kilometerHoursSpeed" {
                        if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                            weather.windSpeed = (windSpeed * milesHourToKilometerHour).string
                            weather.beaufortScale = getBeaufortForce(windSpeed * milesHourToKnot)
                            self.plotData.append(windSpeed * milesHourToKilometerHour)
                        } else {
                            weather.windSpeed = (windSpeed * meterSecondToKilometerHour).string
                            weather.beaufortScale = getBeaufortForce(windSpeed * meterSecondToKnot)
                            self.plotData.append(windSpeed * meterSecondToKilometerHour)
                        }
                    }
                    if Preferences.shared.getPreference("windSpeed") == "knotSpeed" {
                        if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                            weather.windSpeed = (windSpeed * milesHourToKnot).string
                            weather.beaufortScale = getBeaufortForce(windSpeed * milesHourToKnot)
                            self.plotData.append(windSpeed * milesHourToKnot)
                        } else {
                            weather.windSpeed = (windSpeed * meterSecondToKnot).string
                            weather.beaufortScale = getBeaufortForce(windSpeed * meterSecondToKnot)
                            self.plotData.append(windSpeed * meterSecondToKnot)
                        }
                    }
                    if Preferences.shared.getPreference("windSpeed") == "milesHoursSpeed" {
                        if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                            weather.windSpeed = windSpeed.string
                            weather.beaufortScale = getBeaufortForce(windSpeed * milesHourToKnot)
                        } else {
                            weather.windSpeed = (windSpeed * meterSecondToMilesHour).string
                            weather.beaufortScale = getBeaufortForce(windSpeed * meterSecondToKnot)
                            self.plotData.append(windSpeed * meterSecondToMilesHour)
                        }
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        weather.beaufortScaleWindColour = getBeaufortForceColor(windSpeed * milesHourToKnot)
                    } else {
                        weather.beaufortScaleWindColour = getBeaufortForceColor(windSpeed * meterSecondToKnot)
                    }
                }
                //7-8-9
                if let windAngle = Double(json["list"][i]["wind"]["deg"].stringValue) {
                    weather.windDegree = String(format: "%3.1f", windAngle)
                    weather.windName = getWindName(windAngle)
                    self.plotDataWindName.append(weather.windName)
                }
                //10
                if let rain = Double(json["list"][i]["rain"]["1h"].stringValue) {
                    weather.rain1h = String(format: "%3.1f", rain) + " " + loc("MILLIMETERS")
                }
                //11
                if let rain = Double(json["list"][i]["rain"]["3h"].stringValue) {
                    weather.rain3h = String(format: "%3.1f", rain) + " " + loc("MILLIMETERS")
                }
                //12
                if let vis = Double(json["list"][i]["main"]["visibility"].stringValue) {
                    weather.visibility = String(format: "%3.1f", vis/1000) + " " + loc("KILOMETERS")
                }
                //13
                if let pres = Double(json["list"][i]["main"]["pressure"].stringValue) {
                    if Preferences.shared.getPreference("pressureUnit") == "atm" {
                        weather.pressure = String(format: "%3.3f", pres * hpaToAtm) + " " + loc("ATM")
                    }
                    if Preferences.shared.getPreference("pressureUnit") == "bar" {
                        weather.pressure = String(format: "%3.3f", pres * hpaToBar) + " " + loc("BAR")
                    }
                    if Preferences.shared.getPreference("pressureUnit") == "hPa" {
                        weather.pressure = String(format: "%3.1f", pres) + " " + loc("HPA")
                    }
                }
                //14
                if let pres = Double(json["list"][i]["main"]["sea_level"].stringValue) {
                    if Preferences.shared.getPreference("pressureUnit") == "atm" {
                        weather.pressureSeaLevel = String(format: "%3.3f", pres * hpaToAtm) + " " + loc("ATM")
                    }
                    if Preferences.shared.getPreference("pressureUnit") == "bar" {
                        weather.pressureSeaLevel = String(format: "%3.3f", pres * hpaToBar) + " " + loc("BAR")
                    }
                    if Preferences.shared.getPreference("pressureUnit") == "hPa" {
                        weather.pressureSeaLevel = String(format: "%3.1f", pres) + " " + loc("HPA")
                    }
                }
                //15
                if let pres = Double(json["list"][i]["main"]["grnd_level"].stringValue) {
                    if Preferences.shared.getPreference("pressureUnit") == "atm" {
                        weather.pressureGroundLevel = String(format: "%3.3f", pres * hpaToAtm) + " " + loc("ATM")
                    }
                    if Preferences.shared.getPreference("pressureUnit") == "bar" {
                        weather.pressureGroundLevel = String(format: "%3.3f", pres * hpaToBar) + " " + loc("BAR")
                    }
                    if Preferences.shared.getPreference("pressureUnit") == "hPa" {
                        weather.pressureGroundLevel = String(format: "%3.1f", pres) + " " + loc("HPA")
                    }
                }
                //16
                if let hum = Double(json["list"][i]["main"]["humidity"].stringValue) {
                    weather.umidity = hum.string + " " + loc("PERCENT")
                }
                //17
                if let temp = Double(json["list"][i]["main"]["temp"].stringValue) {
                    if Preferences.shared.getPreference("weatherTemp") == "celsusTemp" {
                        weather.temp = String(format: "%3.0f", temp) + " " + loc("CELSUS")
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        weather.temp = String(format: "%3.0f", temp) + " " + loc("FAHRENHEIT")
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "kelvinTemp" {
                        weather.temp = String(format: "%3.0f", temp) + " " + loc("KELVIN")
                    }
                }
                //18
                if let tempMin = Double(json["list"][i]["main"]["temp_min"].stringValue) {
                    if Preferences.shared.getPreference("weatherTemp") == "celsusTemp" {
                        weather.tempMin = String(format: "%3.1f", tempMin) + " " + loc("CELSUS")
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        weather.tempMin = String(format: "%3.1f", tempMin) + " " + loc("FAHRENHEIT")
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "kelvinTemp" {
                        weather.tempMin = String(format: "%3.1f", tempMin) + " " + loc("KELVIN")
                    }
                }
                //19
                if let tempMax = Double(json["list"][i]["main"]["temp_max"].stringValue) {
                    if Preferences.shared.getPreference("weatherTemp") == "celsusTemp" {
                        weather.tempMax = String(format: "%3.1f", tempMax) + " " + loc("CELSUS")
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        weather.tempMax = String(format: "%3.1f", tempMax) + " " + loc("FAHRENHEIT")
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "kelvinTemp" {
                        weather.tempMax = String(format: "%3.1f", tempMax) + " " + loc("KELVIN")
                    }
                }
                //20-21-22-23
                if let dateTime = json["list"][i]["dt_txt"].string {
                    if let dt = dateTime.date(withFormat: "yyyy-MM-dd HH:mm:ss") {
                        var date = dt.string(withFormat: "EEEE, dd/MM/yyyy")
                        date.firstCharacterUppercased()
                        weather.date = date
                        weather.time = dt.string(withFormat: "HH:mm")
                        weather.dateTime = dt.string(withFormat: "dd/MM/yyyy - HH:mm:ss")
                        self.plotDataTime.append(dt.string(withFormat: "HH:mm"))
                    }
                }
                //24
                if let rain = Double(json["list"][i]["rain"]["3h"].stringValue) {
                    weather.rain3h = String(format: "%3.1f", rain) + " " + loc("MILLIMETERS")
                } else {
                    weather.rain3h = "0.0 " + loc("MILLIMETERS")
                }
                //25
                if let snow = Double(json["list"][i]["snow"]["3h"].stringValue) {
                    weather.snow3h = String(format: "%3.1f", snow) + " " + loc("MILLIMETERS")
                } else {
                    weather.snow3h = "0.0 " + loc("MILLIMETERS")
                }
                //26
                if let clouds = Double(json["list"][i]["clouds"]["all"].stringValue) {
                    weather.clouds = clouds.string + " " + loc("PERCENT")
                }
                
                self.forecast.append(weather)
            }
            
            
            DispatchQueue.main.async {
                self.delegate?.forecastDataReady(forecast: self.forecast)
            }
        }
    }
    
    /// Get the forecast data object
    open func getOldForecastData() -> [WeatherModel] {
        return forecast
    }
    
    /// Get the plot data object
    open func getOldplotDataWindName() -> PlotInfoModel {
        return PlotInfoModel(plotDataWindName, plotData, plotDataTime)
    }
    
}
