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

public protocol MRGpsDataGetterWeatherDataDelegate: NSObjectProtocol {
    func weatherDataNotAvaiable(error: String)
    func weatherDataReady(weather: GpsWeatherModel)
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
            self.delegate?.weatherDataNotAvaiable(error: "openWeatherMapKey is NaN")
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
            "lat"           : "\(currentLocation.coordinate.latitude)",
            "lon"           : "\(currentLocation.coordinate.longitude)",
            "type"          : "accurate",
            "units"         : "\(units)",
            "lang"          : loc("LANG"),
            "appid"         : openWeatherMapKey
        ]
        print("Weather openweathermap API ENDPOINT iOS " + urlString)
        
        AFManager.request(urlString, parameters: parameters).responseJSON { response in
            if let er = response.error {
                self.delegate?.weatherDataNotAvaiable(error: er.localizedDescription)
                return
            }
            guard let ilJson = response.value else {
                print("JSON Nil")
                self.delegate?.weatherDataNotAvaiable(error: "JSON is nil")
                return
            }
            let json = JSON(ilJson)
            if let openWeatherMapError = Int(json["cod"].stringValue) {
                if (openWeatherMapError != 200) {
                    self.delegate?.weatherDataNotAvaiable(error: "OpenWeatherMap.org error: " + "\(openWeatherMapError)")
                    return
                }
            }
            
            //0
            self.weather.posizioneCorrente = currentLocation
            //1
            if let weatherDescr = json["weather"][0]["description"].string {
                self.weather.descrizioneTempo = weatherDescr
            }
            //2
            if let weatherIcon = json["weather"][0]["icon"].string {
                self.weather.nomeIconaMeteo = weatherIcon
            }
            //3
            if let velVento = Double(json["wind"]["speed"].stringValue) {
                if Preferences.shared.getPreference("windSpeed") == "meterSecondSpeed" {
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        self.weather.velocitaVento = String(velVento * milesHourToMeterSecond)
                        self.weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * milesHourToKnot) + ": " + String(format: "%3.1f ", velVento * milesHourToKnot)
                    } else {
                        self.weather.velocitaVento = String(velVento)
                        self.weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * meterSecondToKnot) + ": " + String(format: "%3.1f ", velVento)
                    }
                }
                if Preferences.shared.getPreference("windSpeed") == "kilometerHoursSpeed" {
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        self.weather.velocitaVento = String(velVento * milesHourToKilometerHour)
                        self.weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * milesHourToKnot) + ": " + String(format: "%3.1f ", velVento * milesHourToKnot)
                    } else {
                        self.weather.velocitaVento = String(velVento * meterSecondToKilometerHour)
                        self.weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * meterSecondToKnot) + ": " + String(format: "%3.1f ", velVento * meterSecondToKilometerHour)
                    }
                }
                if Preferences.shared.getPreference("windSpeed") == "knotSpeed" {
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        self.weather.velocitaVento = String(velVento * milesHourToKnot)
                        self.weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * milesHourToKnot) + ": " + String(format: "%3.1f ", velVento * milesHourToKnot)
                    } else {
                        self.weather.velocitaVento = String(velVento * meterSecondToKnot)
                        self.weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * meterSecondToKnot) + ": " + String(format: "%3.1f ", velVento * meterSecondToKnot)
                    }
                }
                if Preferences.shared.getPreference("windSpeed") == "milesHoursSpeed" {
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        self.weather.velocitaVento = String(velVento)
                        self.weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * milesHourToKnot) + ": " + String(format: "%3.1f ", velVento)
                    } else {
                        self.weather.velocitaVento = String(velVento * meterSecondToMilesHour)
                        self.weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * meterSecondToKnot) + ": " + String(format: "%3.1f ", velVento * meterSecondToMilesHour)
                    }
                }
                if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                    self.weather.coloreBollinoVento = getBeaufortForceColor(velVento * milesHourToKnot)
                } else {
                    self.weather.coloreBollinoVento = getBeaufortForceColor(velVento * meterSecondToKnot)
                }
            }
            //4-5
            if let angVento = Double(json["wind"]["deg"].stringValue) {
                self.weather.angoloVento = String(format: "%3.1f", angVento)
                self.weather.nomeVento = getWindName(angVento)
//                self.weather.nomeIconaVento = setWindDirectionImage(angVento)
            }
            //6
            if let rain = Double(json["rain"]["1h"].stringValue) {
                self.weather.precipitazioni1h = String(format: "%3.1f", rain) + " " + loc("MILLIMETERS")
            } else {
                self.weather.precipitazioni1h = String("0.0") + " " + loc("MILLIMETERS")
            }
            //6.2
            if let rain = Double(json["rain"]["3h"].stringValue) {
                self.weather.precipitazioni3h = String(format: "%3.1f", rain) + " " + loc("MILLIMETERS")
            } else {
                self.weather.precipitazioni3h = String("0.0") + " " + loc("MILLIMETERS")
            }
            //7
            if let vis = Double(json["visibility"].stringValue) {
                self.weather.visibilita = String(format: "%3.1f", vis/1000) + " " + loc("KILOMETERS")
            }
            //8
            if let pres = Double(json["main"]["pressure"].stringValue) {
                if Preferences.shared.getPreference("pressureUnit") == "atm" {
                    self.weather.pressione = String(format: "%3.3f", pres * hpaToAtm) + " " + loc("ATM")
                }
                if Preferences.shared.getPreference("pressureUnit") == "bar" {
                    self.weather.pressione = String(format: "%3.3f", pres * hpaToBar) + " " + loc("BAR")
                }
                if Preferences.shared.getPreference("pressureUnit") == "hPa" {
                    self.weather.pressione = String(format: "%3.1f", pres) + " " + loc("HPA")
                }
            }
            //9
            if let pres = Double(json["main"]["sea_level"].stringValue) {
                if Preferences.shared.getPreference("pressureUnit") == "atm" {
                    self.weather.pressioneMare = String(format: "%3.3f", pres * hpaToAtm) + " " + loc("ATM")
                }
                if Preferences.shared.getPreference("pressureUnit") == "bar" {
                    self.weather.pressioneMare = String(format: "%3.3f", pres * hpaToBar) + " " + loc("BAR")
                }
                if Preferences.shared.getPreference("pressureUnit") == "hPa" {
                    self.weather.pressioneMare = String(format: "%3.1f", pres) + " " + loc("HPA")
                }
            }
            //10
            if let pres = Double(json["main"]["grnd_level"].stringValue) {
                if Preferences.shared.getPreference("pressureUnit") == "atm" {
                    self.weather.pressioneSuolo = String(format: "%3.3f", pres * hpaToAtm) + " " + loc("ATM")
                }
                if Preferences.shared.getPreference("pressureUnit") == "bar" {
                    self.weather.pressioneSuolo = String(format: "%3.3f", pres * hpaToBar) + " " + loc("BAR")
                }
                if Preferences.shared.getPreference("pressureUnit") == "hPa" {
                    self.weather.pressioneSuolo = String(format: "%3.1f", pres) + " " + loc("HPA")
                }
            } else {
                self.weather.pressioneSuolo = self.weather.pressione
            }
            //11
            if let hum = Double(json["main"]["humidity"].stringValue) {
                self.weather.umidita = "\(hum)" + " " + loc("PERCENT")
            }
            //12
            if let temp = Double(json["main"]["temp"].stringValue) {
                if Preferences.shared.getPreference("weatherTemp") == "celsusTemp" {
                    self.weather.temperatura = String(format: "%3.1f", temp) + " " + loc("CELSUS")
                }
                if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                    self.weather.temperatura = String(format: "%3.1f", temp) + " " + loc("FAHRENHEIT")
                }
                if Preferences.shared.getPreference("weatherTemp") == "kelvinTemp" {
                    self.weather.temperatura = String(format: "%3.1f", temp) + " " + loc("KELVIN")
                }
            }
            //13
            if let tempMin = Double(json["main"]["temp_min"].stringValue) {
                if Preferences.shared.getPreference("weatherTemp") == "celsusTemp" {
                    self.weather.temperaturaMin = String(format: "%3.1f", tempMin) + " " + loc("CELSUS")
                }
                if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                    self.weather.temperaturaMin = String(format: "%3.1f", tempMin) + " " + loc("FAHRENHEIT")
                }
                if Preferences.shared.getPreference("weatherTemp") == "kelvinTemp" {
                    self.weather.temperaturaMin = String(format: "%3.1f", tempMin) + " " + loc("KELVIN")
                }
            }
            //14
            if let tempMax = Double(json["main"]["temp_max"].stringValue) {
                if Preferences.shared.getPreference("weatherTemp") == "celsusTemp" {
                    self.weather.temperaturaMax = String(format: "%3.1f", tempMax) + " " + loc("CELSUS")
                }
                if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                    self.weather.temperaturaMax = String(format: "%3.1f", tempMax) + " " + loc("FAHRENHEIT")
                }
                if Preferences.shared.getPreference("weatherTemp") == "kelvinTemp" {
                    self.weather.temperaturaMax = String(format: "%3.1f", tempMax) + " " + loc("KELVIN")
                }
            }
            //15
            if let snow = Double(json["snow"]["1h"].stringValue) {
                self.weather.neve1h = String(format: "%3.1f", snow) + " " + loc("MILLIMETERS")
            } else {
                self.weather.neve1h = String("0.0") + " " + loc("MILLIMETERS")
            }
            //16
            if let snow = Double(json["snow"]["3h"].stringValue) {
                self.weather.neve3h = String(format: "%3.1f", snow) + " " + loc("MILLIMETERS")
            } else {
                self.weather.neve3h = String("0.0") + " " + loc("MILLIMETERS")
            }
            //17
            if let clouds = Double(json["clouds"]["all"].stringValue) {
                self.weather.nuvole = "\(clouds)" + " " + loc("PERCENT")
            }
            
            self.delegate?.weatherDataReady(weather: self.weather)
        }
    }
    
    open func getOldWeatherData() -> GpsWeatherModel {
        return weather
    }
    
}
