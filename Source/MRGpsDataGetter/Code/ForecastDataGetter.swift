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

@objc public protocol MRGpsDataGetterForecastDataDelegate: NSObjectProtocol {
    func forecastDataReady(forecast: [GpsWeatherModel])
    @objc optional func forecastDataNotAvaiable(error: String)
}

open class ForecastDataGetter: NSObject {
    
    public static let shared = ForecastDataGetter()
    open weak var delegate : MRGpsDataGetterForecastDataDelegate?
    
    var forecast : [GpsWeatherModel] = []
    var plotDataWindName: [String] = []
    var plotData: [Double] = []
    var plotDataTime: [String] = []
    
    
    open func getForecastInfo(openWeatherMapKey: String, currentLocation: CLLocation) {
        DispatchQueue.global().async {
            self.getForecastInfoFromWeb(openWeatherMapKey, currentLocation)
        }
    }
    
    private func getForecastInfoFromWeb(_ openWeatherMapKey: String, _ currentLocation: CLLocation) {
        if openWeatherMapKey == "NaN" {
            self.delegate?.forecastDataNotAvaiable?(error: "openWeatherMapKey is NaN")
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
            "lat"           : "\(currentLocation.coordinate.latitude)",
            "lon"           : "\(currentLocation.coordinate.longitude)",
            "type"          : "accurate",
            "units"         : "\(units)",
            "lang"          : loc("LANG"),
            "appid"         : openWeatherMapKey
        ]
        print("Forecast openweathermap API ENDPOINT iOS " + urlString)
        
        AFManager().request(urlString, parameters: parameters).responseJSON { response in
            if let er = response.error {
                self.delegate?.forecastDataNotAvaiable?(error: er.localizedDescription)
                return
            }
            guard let ilJson = response.value else {
                self.delegate?.forecastDataNotAvaiable?(error: "JSON Nil")
                return
            }
            let json = JSON(ilJson)
            if let openWeatherMapError = Int(json["cod"].stringValue) {
                if (openWeatherMapError != 200) {
                    self.delegate?.forecastDataNotAvaiable?(error: "openWeatherMap.org error: " + "\(openWeatherMapError)")
                    return
                }
            }
            
            self.forecast = []
            self.plotData = []
            self.plotDataTime = []
            self.plotDataWindName = []
            for i in 0..<json["list"].count {
                let weather = GpsWeatherModel()
                
                //0
                weather.currentLocation = currentLocation
                //1
                if let weatherDescr = json["list"][i]["weather"][0]["description"].string {
                    weather.weatherDescription = weatherDescr
                }
                //2
                if let weatherIcon = json["list"][i]["weather"][0]["icon"].string {
                    weather.weatherOpenWeatherMapIcon = weatherIcon
                }
                //3-4-5-6
                if let velVento = Double(json["list"][i]["wind"]["speed"].stringValue) {
                    if Preferences.shared.getPreference("windSpeed") == "meterSecondSpeed" {
                        if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                            weather.windSpeed = String(velVento * milesHourToMeterSecond)
                            weather.beaufortScale = /*loc("positionWind_SCALABEAUFORT") + " " +*/ getBeaufortForce(velVento * milesHourToKnot) /*+ ": " + String(format: "%3.1f ", velVento * milesHourToMeterSecond)*/
                            self.plotData.append(velVento * milesHourToMeterSecond)
                        } else {
                            weather.windSpeed = String(velVento)
                            weather.beaufortScale = /*loc("positionWind_SCALABEAUFORT") + " " +*/ getBeaufortForce(velVento * meterSecondToKnot) /*+ ": " + String(format: "%3.1f ", velVento)*/
                            self.plotData.append(velVento)
                        }
                    }
                    if Preferences.shared.getPreference("windSpeed") == "kilometerHoursSpeed" {
                        if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                            weather.windSpeed = String(velVento * milesHourToKilometerHour)
                            weather.beaufortScale = /*loc("positionWind_SCALABEAUFORT") + " " +*/ getBeaufortForce(velVento * milesHourToKnot) /*+ ": " + String(format: "%3.1f ", velVento * milesHourToKilometerHour)*/
                            self.plotData.append(velVento * milesHourToKilometerHour)
                        } else {
                            weather.windSpeed = String(velVento * meterSecondToKilometerHour)
                            weather.beaufortScale = /*loc("positionWind_SCALABEAUFORT") + " " +*/ getBeaufortForce(velVento * meterSecondToKnot) /*+ ": " + String(format: "%3.1f ", velVento * meterSecondToKilometerHour)*/
                            self.plotData.append(velVento * meterSecondToKilometerHour)
                        }
                    }
                    if Preferences.shared.getPreference("windSpeed") == "knotSpeed" {
                        if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                            weather.windSpeed = String(velVento * milesHourToKnot)
                            weather.beaufortScale = /*loc("positionWind_SCALABEAUFORT") + " " +*/ getBeaufortForce(velVento * milesHourToKnot) /*+ ": " + String(format: "%3.1f ", velVento * milesHourToKnot)*/
                            self.plotData.append(velVento * milesHourToKnot)
                        } else {
                            weather.windSpeed = String(velVento * meterSecondToKnot)
                            weather.beaufortScale = /*loc("positionWind_SCALABEAUFORT") + " " +*/ getBeaufortForce(velVento * meterSecondToKnot) /*+ ": " + String(format: "%3.1f ", velVento * meterSecondToKnot)*/
                            self.plotData.append(velVento * meterSecondToKnot)
                        }
                    }
                    if Preferences.shared.getPreference("windSpeed") == "milesHoursSpeed" {
                        if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                            weather.windSpeed = String(velVento)
                            weather.beaufortScale = /*loc("positionWind_SCALABEAUFORT") + " " +*/ getBeaufortForce(velVento * milesHourToKnot) /*+ ": " + String(format: "%3.1f ", velVento)
                            self.plotData.append(velVento)*/
                        } else {
                            weather.windSpeed = String(velVento * meterSecondToMilesHour)
                            weather.beaufortScale = /*loc("positionWind_SCALABEAUFORT") + " " +*/ getBeaufortForce(velVento * meterSecondToKnot) /*+ ": " + String(format: "%3.1f ", velVento * meterSecondToMilesHour)*/
                            self.plotData.append(velVento * meterSecondToMilesHour)
                        }
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        weather.beaufortScaleWindColour = getBeaufortForceColor(velVento * milesHourToKnot)
                    } else {
                        weather.beaufortScaleWindColour = getBeaufortForceColor(velVento * meterSecondToKnot)
                    }
                }
                //7-8-9
                if let angVento = Double(json["list"][i]["wind"]["deg"].stringValue) {
                    weather.windDegree = String(format: "%3.1f", angVento)
                    weather.windName = getWindName(angVento)
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
                    weather.umidity = "\(hum)" + " " + loc("PERCENT")
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
                    if let dt = dateTime.toDate(format: "yyyy-MM-dd HH:mm:ss"), let data = UTCToLocal(dt, 4), let ora = UTCToLocal(dt, 3), let dataOra = UTCToLocal(dt, 2) {
                        weather.date = data.firstUppercased
                        weather.time = ora
                        weather.dateTime = dataOra
                        self.plotDataTime.append(ora)
                    }
                }
                //24
                if let rain = Double(json["list"][i]["rain"]["3h"].stringValue) {
                    weather.rain3h = String(format: "%3.1f", rain) + " " + loc("MILLIMETERS")
                } else {
                    weather.rain3h = String("0.0") + " " + loc("MILLIMETERS")
                }
                //25
                if let snow = Double(json["list"][i]["snow"]["3h"].stringValue) {
                    weather.snow3h = String(format: "%3.1f", snow) + " " + loc("MILLIMETERS")
                } else {
                    weather.snow3h = String("0.0") + " " + loc("MILLIMETERS")
                }
                //26
                if let clouds = Double(json["list"][i]["clouds"]["all"].stringValue) {
                    weather.clouds = "\(clouds)" + " " + loc("PERCENT")
                }
                
                self.forecast.append(weather)
            }
            
            self.delegate?.forecastDataReady(forecast: self.forecast)
        }
    }
    
    open func getOldForecastData() -> [GpsWeatherModel] {
        return forecast
    }
    
    open func getOldplotDataWindName() -> GpsPlotInfoModel {
        return GpsPlotInfoModel(plotDataWindName, plotData, plotDataTime)
    }
    
}
