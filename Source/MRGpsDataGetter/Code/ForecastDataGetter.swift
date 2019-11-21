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

public protocol MRGpsDataGetterForecastDataDelegate: NSObjectProtocol {
    func forecastDataNotAvaiable(error: String)
    func forecastDataReady(forecast: [GpsWeatherModel])
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
            self.delegate?.forecastDataNotAvaiable(error: "openWeatherMapKey is NaN")
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
        
        AFManager.request(urlString, parameters: parameters).responseJSON { response in
            if let er = response.error {
                self.delegate?.forecastDataNotAvaiable(error: er.localizedDescription)
                return
            }
            guard let ilJson = response.value else {
                self.delegate?.forecastDataNotAvaiable(error: "JSON Nil")
                return
            }
            let json = JSON(ilJson)
            if let openWeatherMapError = Int(json["cod"].stringValue) {
                if (openWeatherMapError != 200) {
                    self.delegate?.forecastDataNotAvaiable(error: "openWeatherMap.org error: " + "\(openWeatherMapError)")
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
                weather.posizioneCorrente = currentLocation
                //1
                if let weatherDescr = json["list"][i]["weather"][0]["description"].string {
                    weather.descrizioneTempo = weatherDescr
                }
                //2
                if let weatherIcon = json["list"][i]["weather"][0]["icon"].string {
                    weather.nomeIconaMeteo = weatherIcon
                }
                //3-4-5
                if let velVento = Double(json["list"][i]["wind"]["speed"].stringValue) {
                    if Preferences.shared.getPreference("windSpeed") == "meterSecondSpeed" {
                        if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                            weather.velocitaVento = String(velVento * milesHourToMeterSecond)
                            weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * milesHourToKnot) + ": " + String(format: "%3.1f ", velVento * milesHourToMeterSecond)
                            self.plotData.append(velVento * milesHourToMeterSecond)
                        } else {
                            weather.velocitaVento = String(velVento)
                            weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * meterSecondToKnot) + ": " + String(format: "%3.1f ", velVento)
                            self.plotData.append(velVento)
                        }
                    }
                    if Preferences.shared.getPreference("windSpeed") == "kilometerHoursSpeed" {
                        if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                            weather.velocitaVento = String(velVento * milesHourToKilometerHour)
                            weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * milesHourToKnot) + ": " + String(format: "%3.1f ", velVento * milesHourToKilometerHour)
                            self.plotData.append(velVento * milesHourToKilometerHour)
                        } else {
                            weather.velocitaVento = String(velVento * meterSecondToKilometerHour)
                            weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * meterSecondToKnot) + ": " + String(format: "%3.1f ", velVento * meterSecondToKilometerHour)
                            self.plotData.append(velVento * meterSecondToKilometerHour)
                        }
                    }
                    if Preferences.shared.getPreference("windSpeed") == "knotSpeed" {
                        if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                            weather.velocitaVento = String(velVento * milesHourToKnot)
                            weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * milesHourToKnot) + ": " + String(format: "%3.1f ", velVento * milesHourToKnot)
                            self.plotData.append(velVento * milesHourToKnot)
                        } else {
                            weather.velocitaVento = String(velVento * meterSecondToKnot)
                            weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * meterSecondToKnot) + ": " + String(format: "%3.1f ", velVento * meterSecondToKnot)
                            self.plotData.append(velVento * meterSecondToKnot)
                        }
                    }
                    if Preferences.shared.getPreference("windSpeed") == "milesHoursSpeed" {
                        if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                            weather.velocitaVento = String(velVento)
                            weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * milesHourToKnot) + ": " + String(format: "%3.1f ", velVento)
                            self.plotData.append(velVento)
                        } else {
                            weather.velocitaVento = String(velVento * meterSecondToMilesHour)
                            weather.forzaScalaBeaufortVento = loc("positionWind_SCALABEAUFORT") + " " + getBeaufortForce(velVento * meterSecondToKnot) + ": " + String(format: "%3.1f ", velVento * meterSecondToMilesHour)
                            self.plotData.append(velVento * meterSecondToMilesHour)
                        }
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        weather.coloreBollinoVento = getBeaufortForceColor(velVento * milesHourToKnot)
                    } else {
                        weather.coloreBollinoVento = getBeaufortForceColor(velVento * meterSecondToKnot)
                    }
                }
                //6-7-8
                if let angVento = Double(json["list"][i]["wind"]["deg"].stringValue) {
                    weather.angoloVento = String(format: "%3.1f", angVento)
                    weather.nomeVento = getWindName(angVento)
                    weather.nomeIconaVento = setWindDirectionImage(angVento)
                    self.plotDataWindName.append(weather.nomeVento)
                }
                //9
                if let rain = Double(json["list"][i]["rain"]["1h"].stringValue) {
                    weather.precipitazioni1h = String(format: "%3.1f", rain) + " " + loc("MILLIMETERS")
                }
                //9.2
                if let rain = Double(json["list"][i]["rain"]["3h"].stringValue) {
                    weather.precipitazioni3h = String(format: "%3.1f", rain) + " " + loc("MILLIMETERS")
                }
                //10
                if let vis = Double(json["list"][i]["main"]["visibility"].stringValue) {
                    weather.visibilita = String(format: "%3.1f", vis/1000) + " " + loc("KILOMETERS")
                }
                //11
                if let pres = Double(json["list"][i]["main"]["pressure"].stringValue) {
                    if Preferences.shared.getPreference("pressureUnit") == "atm" {
                        weather.pressione = String(format: "%3.3f", pres * hpaToAtm) + " " + loc("ATM")
                    }
                    if Preferences.shared.getPreference("pressureUnit") == "bar" {
                        weather.pressione = String(format: "%3.3f", pres * hpaToBar) + " " + loc("BAR")
                    }
                    if Preferences.shared.getPreference("pressureUnit") == "hPa" {
                        weather.pressione = String(format: "%3.1f", pres) + " " + loc("HPA")
                    }
                }
                //12
                if let pres = Double(json["list"][i]["main"]["sea_level"].stringValue) {
                    if Preferences.shared.getPreference("pressureUnit") == "atm" {
                        weather.pressioneMare = String(format: "%3.3f", pres * hpaToAtm) + " " + loc("ATM")
                    }
                    if Preferences.shared.getPreference("pressureUnit") == "bar" {
                        weather.pressioneMare = String(format: "%3.3f", pres * hpaToBar) + " " + loc("BAR")
                    }
                    if Preferences.shared.getPreference("pressureUnit") == "hPa" {
                        weather.pressioneMare = String(format: "%3.1f", pres) + " " + loc("HPA")
                    }
                }
                //13
                if let pres = Double(json["list"][i]["main"]["grnd_level"].stringValue) {
                    if Preferences.shared.getPreference("pressureUnit") == "atm" {
                        weather.pressioneSuolo = String(format: "%3.3f", pres * hpaToAtm) + " " + loc("ATM")
                    }
                    if Preferences.shared.getPreference("pressureUnit") == "bar" {
                        weather.pressioneSuolo = String(format: "%3.3f", pres * hpaToBar) + " " + loc("BAR")
                    }
                    if Preferences.shared.getPreference("pressureUnit") == "hPa" {
                        weather.pressioneSuolo = String(format: "%3.1f", pres) + " " + loc("HPA")
                    }
                }
                //14
                if let hum = Double(json["list"][i]["main"]["humidity"].stringValue) {
                    weather.umidita = "\(hum)" + " " + loc("PERCENT")
                }
                //15
                if let temp = Double(json["list"][i]["main"]["temp"].stringValue) {
                    if Preferences.shared.getPreference("weatherTemp") == "celsusTemp" {
                        weather.temperatura = String(format: "%3.0f", temp) + " " + loc("CELSUS")
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        weather.temperatura = String(format: "%3.0f", temp) + " " + loc("FAHRENHEIT")
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "kelvinTemp" {
                        weather.temperatura = String(format: "%3.0f", temp) + " " + loc("KELVIN")
                    }
                }
                //16
                if let tempMin = Double(json["list"][i]["main"]["temp_min"].stringValue) {
                    if Preferences.shared.getPreference("weatherTemp") == "celsusTemp" {
                        weather.temperaturaMin = String(format: "%3.1f", tempMin) + " " + loc("CELSUS")
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        weather.temperaturaMin = String(format: "%3.1f", tempMin) + " " + loc("FAHRENHEIT")
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "kelvinTemp" {
                        weather.temperaturaMin = String(format: "%3.1f", tempMin) + " " + loc("KELVIN")
                    }
                }
                //17
                if let tempMax = Double(json["list"][i]["main"]["temp_max"].stringValue) {
                    if Preferences.shared.getPreference("weatherTemp") == "celsusTemp" {
                        weather.temperaturaMax = String(format: "%3.1f", tempMax) + " " + loc("CELSUS")
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "fahrenheitTemp" {
                        weather.temperaturaMax = String(format: "%3.1f", tempMax) + " " + loc("FAHRENHEIT")
                    }
                    if Preferences.shared.getPreference("weatherTemp") == "kelvinTemp" {
                        weather.temperaturaMax = String(format: "%3.1f", tempMax) + " " + loc("KELVIN")
                    }
                }
                //18-19-20-21
                if let dateTime = json["list"][i]["dt_txt"].string {
                    if let dt = dateTime.toDate(format: "yyyy-MM-dd HH:mm:ss"), let data = UTCToLocal(dt, 4), let ora = UTCToLocal(dt, 3), let dataOra = UTCToLocal(dt, 2) {
                        weather.data = data.firstUppercased
                        weather.ora = ora
                        weather.dataOra = dataOra
                        self.plotDataTime.append(ora)
                    }
                }
                //22
                if let rain = Double(json["list"][i]["rain"]["3h"].stringValue) {
                    weather.precipitazioni3h = String(format: "%3.1f", rain) + " " + loc("MILLIMETERS")
                } else {
                    weather.precipitazioni3h = String("0.0") + " " + loc("MILLIMETERS")
                }
                //23
                if let snow = Double(json["list"][i]["snow"]["3h"].stringValue) {
                    weather.neve3h = String(format: "%3.1f", snow) + " " + loc("MILLIMETERS")
                } else {
                    weather.neve3h = String("0.0") + " " + loc("MILLIMETERS")
                }
                //24
                if let clouds = Double(json["list"][i]["clouds"]["all"].stringValue) {
                    weather.nuvole = "\(clouds)" + " " + loc("PERCENT")
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
