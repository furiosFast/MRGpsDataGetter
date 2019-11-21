//
//  SunDataGetter.swift
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

public protocol MRGpsDataGetterSunDataDelegate {
    func sunDataReady(sun: GpsSunInfoModel)
}

public class SunDataGetter: NSObject {
    
    var delegate : MRGpsDataGetterSunDataDelegate? = nil
    let sun = GpsSunInfoModel()
    
    
    public func getSunInfo(currentLocation: CLLocation) {
        DispatchQueue.global().async {
            self.reverseSolarInfo(currentLocation)
        }
    }
    
    private func reverseSolarInfo(_ currentLocation: CLLocation){
        var minutesTimesFlag = 1
        if Bool(Preferences.shared.getPreference("minutesTimes"))! == true {
            minutesTimesFlag = 3
        }
        let myLocationCoordinates = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let Jan12000Date = BDAstroCalc.daysSinceJan12000(date: NSDate())
        
        let sunRiseSet = BDAstroCalc.sunRiseAndSet(date: NSDate(), location: myLocationCoordinates)
        sun.mezzogiornoSolare = UTCToLocal(sunRiseSet.solarNoon as Date, minutesTimesFlag)!
        sun.mezzanotteSolare = UTCToLocal(sunRiseSet.nadir as Date, minutesTimesFlag)!
        
        let sunLocation = BDAstroCalc.sunPosition(date: NSDate(), location: myLocationCoordinates)
        let azim = (sunLocation.azimuth + Double.pi) * radiansToDegrees
        sun.altitudine = String(format: "%3.1f", sunLocation.altitude * radiansToDegrees) + loc("DEGREE")
        sun.azimuth = String(format: "%3.1f", azim) + loc("DEGREE") + " " + getAngleName(azim)
        
        let sunTimes = BDAstroCalc.sunSignificantTimes(date: NSDate(), location: myLocationCoordinates)
        sun.crepuscoloAstronauticoAlba = UTCToLocal(sunTimes["nightEnd"]! as Date, minutesTimesFlag)!
        sun.crepuscoloNauticoAlba = UTCToLocal(sunTimes["nauticalDawn"]! as Date, minutesTimesFlag)!
        sun.crepuscoloCivileAlba = UTCToLocal(sunTimes["dawn"]! as Date, minutesTimesFlag)!
        sun.albaInizio = UTCToLocal(sunTimes["sunriseStart"]! as Date, minutesTimesFlag)!
        sun.albaFine = UTCToLocal(sunTimes["sunriseEnd"]! as Date, minutesTimesFlag)!
        sun.tramontoInizio = UTCToLocal(sunTimes["sunsetStart"]! as Date, minutesTimesFlag)!
        sun.tramontoFine = UTCToLocal(sunTimes["sunsetEnd"]! as Date, minutesTimesFlag)!
        sun.crepuscoloCivileTramonto = UTCToLocal(sunTimes["dusk"]! as Date, minutesTimesFlag)!
        sun.crepuscoloNauticoTramonto = UTCToLocal(sunTimes["nauticalDusk"]! as Date, minutesTimesFlag)!
        sun.crepuscoloAstronauticoTramonto = UTCToLocal(sunTimes["nightStart"]! as Date, minutesTimesFlag)!
        
        sun.oraBluAlbaInizio = UTCToLocal(sunTimes["dawn"]! as Date, minutesTimesFlag)!
        sun.oraBluAlbaFine = UTCToLocal((sunTimes["dawn"]! as Date).plusMinutes((Date.minutesBetween(date1: (sunTimes["dawn"]! as Date), date2: (sunTimes["sunriseStart"]! as Date))/2)), minutesTimesFlag)!
        sun.oraBluTramontoInizio = UTCToLocal((sunTimes["sunsetEnd"]! as Date).plusMinutes((Date.minutesBetween(date1: (sunTimes["sunsetEnd"]! as Date), date2: (sunTimes["dusk"]! as Date))/2)), minutesTimesFlag)!
        sun.oraBluTramontoFine = UTCToLocal(sunTimes["dusk"]! as Date, minutesTimesFlag)!
        
        sun.oraDoroAlbaInizio = UTCToLocal((sunTimes["dawn"]! as Date).plusMinutes((Date.minutesBetween(date1: (sunTimes["dawn"]! as Date), date2: (sunTimes["sunriseStart"]! as Date))/2)), minutesTimesFlag)!
        sun.oraDoroAlbaFine = UTCToLocal(sunTimes["goldenHourEnd"]! as Date, minutesTimesFlag)!
        sun.oraDoroTramontoInizio = UTCToLocal(sunTimes["goldenHourStart"]! as Date, minutesTimesFlag)!
        sun.oraDoroTramontoFine = UTCToLocal((sunTimes["sunsetEnd"]! as Date).plusMinutes((Date.minutesBetween(date1: (sunTimes["sunsetEnd"]! as Date), date2: (sunTimes["dusk"]! as Date))/2)), minutesTimesFlag)!
        
        sun.oreLuce = setTodayDaylightHours(sunTimes, BDAstroCalc.sunSignificantTimes(date: Date().yesterday as NSDate, location: myLocationCoordinates))
        sun.faseSolare = setSunPhase(sunLocation.altitude * radiansToDegrees)
        
        let sunCoordinates = BDAstroCalc.sunCoordinates(daysSinceJan12000: Jan12000Date)
        sun.declinazione = declinationToString(sunCoordinates.declination * radiansToDegrees)
        sun.rettaAscendente = String(format: "%3.1f", sunCoordinates.rightAscension  * radiansToDegrees)
        sun.segnoZodiacale = getZodiacSign(sunCoordinates.rightAscension * radiansToDegrees)
        
        DispatchQueue.main.async {
            self.delegate?.sunDataReady(sun: self.sun)
        }
    }
    
    //MARK: - Support functions for sun
    private func setTodayDaylightHours(_ today: [String : NSDate], _ yesterday: [String : NSDate]) -> String {
        let todayTime = setDaylightHoursDifference(today["sunsetEnd"]! as Date, today["sunriseStart"]! as Date)
        let yesterdayTime = setDaylightHoursDifference(yesterday["sunsetEnd"]! as Date, yesterday["sunriseStart"]! as Date)
        if let t = todayTime.toDate(format: "HH:mm:ss"), let y = yesterdayTime.toDate(format: "HH:mm:ss") {
            if(t.isGreaterThan(y)) {
                return todayTime + " (+" + setDaylightHoursDifference(t, y) + ")"
            } else {
                return todayTime + " (-" + setDaylightHoursDifference(t, y) + ")"
            }
        } else {
            return todayTime
        }
    }
    
    private func setDaylightHoursDifference(_ sunrise: Date, _ sunset: Date) -> String {
        let hours = Date.hoursBetween(date1: sunset, date2: sunrise)
        var h = ""
        if(hours < 10) {
            h = "0\(hours):"
        } else {
            h = "\(hours):"
        }
        if(hours < 1) {
            h = ""
        }
        
        let minutes = Date.minutesBetween(date1: sunset, date2: sunrise)
        var m = ""
        if(minutes > -10 && minutes < 10) {
            m = "0\(minutes)"
        } else {
            m = "\(minutes)"
        }
        if(minutes < 0) {
            m = m.replacingOccurrences(of: "-", with: "")
        }
        
        let seconds = Date.secondsBetween(date1: sunset, date2: sunrise)
        var s = ""
        if(seconds > -10 && seconds < 10) {
            s = "0\(seconds)"
        } else {
            s = "\(seconds)"
        }
        if(seconds < 0) {
            s = s.replacingOccurrences(of: "-", with: "")
        }
        
        return "\(h)" + "\(m)" + ":" + "\(s)"
    }
    
    private func setSunPhase(_ altitude: Double) -> String {
        if (altitude > 0) {
            return loc("position_DAYTITLE")
        }
        if (altitude <= 0 && altitude >= -6) {
            return loc("position_CREPCIVSUNRISETITLE")
        }
        if (altitude < -6 && altitude >= -12) {
            return loc("position_CREPNAUTICSUNRISETITLE")
        }
        if (altitude < -12 && altitude >= -18) {
            return loc("position_CREPASTROSUNRISETITLE")
        }
        if (altitude < -18) {
            return loc("position_NIGHTTITLE")
        }
        return loc("NOTAVAIABLENUMBER")
    }
    
}
