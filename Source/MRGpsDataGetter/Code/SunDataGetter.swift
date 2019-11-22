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

public protocol MRGpsDataGetterSunDataDelegate: NSObjectProtocol {
    func sunDataReady(sun: GpsSunInfoModel)
}

open class SunDataGetter: NSObject {
    
    public static let shared = SunDataGetter()
    open weak var delegate: MRGpsDataGetterSunDataDelegate?
    
    let sun = GpsSunInfoModel()
    
    
    open func getSunInfo(currentLocation: CLLocation) {
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
        sun.solarNoon = UTCToLocal(sunRiseSet.solarNoon as Date, minutesTimesFlag)!
        sun.nadir = UTCToLocal(sunRiseSet.nadir as Date, minutesTimesFlag)!
        
        let sunLocation = BDAstroCalc.sunPosition(date: NSDate(), location: myLocationCoordinates)
        let azim = (sunLocation.azimuth + Double.pi) * radiansToDegrees
        sun.altitude = String(format: "%3.1f", sunLocation.altitude * radiansToDegrees) + loc("DEGREE")
        sun.azimuth = String(format: "%3.1f", azim) + loc("DEGREE") + " " + getAngleName(azim)
        
        let sunTimes = BDAstroCalc.sunSignificantTimes(date: NSDate(), location: myLocationCoordinates)
        sun.astronomicalDuskSunrise = UTCToLocal(sunTimes["nightEnd"]! as Date, minutesTimesFlag)!
        sun.nauticalDuskSunrise = UTCToLocal(sunTimes["nauticalDawn"]! as Date, minutesTimesFlag)!
        sun.civilDuskSunrise = UTCToLocal(sunTimes["dawn"]! as Date, minutesTimesFlag)!
        sun.sunriseStart = UTCToLocal(sunTimes["sunriseStart"]! as Date, minutesTimesFlag)!
        sun.sunriseEnd = UTCToLocal(sunTimes["sunriseEnd"]! as Date, minutesTimesFlag)!
        sun.sunsetStart = UTCToLocal(sunTimes["sunsetStart"]! as Date, minutesTimesFlag)!
        sun.sunsetEnd = UTCToLocal(sunTimes["sunsetEnd"]! as Date, minutesTimesFlag)!
        sun.civilDuskSunset = UTCToLocal(sunTimes["dusk"]! as Date, minutesTimesFlag)!
        sun.nauticalDuskSunset = UTCToLocal(sunTimes["nauticalDusk"]! as Date, minutesTimesFlag)!
        sun.astronomicalDuskSunset = UTCToLocal(sunTimes["nightStart"]! as Date, minutesTimesFlag)!
        
        sun.blueHourSunriseStart = UTCToLocal(sunTimes["dawn"]! as Date, minutesTimesFlag)!
        sun.blueHourSunriseEnd = UTCToLocal((sunTimes["dawn"]! as Date).plusMinutes((Date.minutesBetween(date1: (sunTimes["dawn"]! as Date), date2: (sunTimes["sunriseStart"]! as Date))/2)), minutesTimesFlag)!
        sun.blueHourSunsetStart = UTCToLocal((sunTimes["sunsetEnd"]! as Date).plusMinutes((Date.minutesBetween(date1: (sunTimes["sunsetEnd"]! as Date), date2: (sunTimes["dusk"]! as Date))/2)), minutesTimesFlag)!
        sun.blueHourSunsetEnd = UTCToLocal(sunTimes["dusk"]! as Date, minutesTimesFlag)!
        
        sun.goldenHourSunriseStart = UTCToLocal((sunTimes["dawn"]! as Date).plusMinutes((Date.minutesBetween(date1: (sunTimes["dawn"]! as Date), date2: (sunTimes["sunriseStart"]! as Date))/2)), minutesTimesFlag)!
        sun.goldenHourSunriseEnd = UTCToLocal(sunTimes["goldenHourEnd"]! as Date, minutesTimesFlag)!
        sun.goldenHourSunsetStart = UTCToLocal(sunTimes["goldenHourStart"]! as Date, minutesTimesFlag)!
        sun.goldenHourSunsetEnd = UTCToLocal((sunTimes["sunsetEnd"]! as Date).plusMinutes((Date.minutesBetween(date1: (sunTimes["sunsetEnd"]! as Date), date2: (sunTimes["dusk"]! as Date))/2)), minutesTimesFlag)!
        
        sun.daylightHours = getTodayDaylightHours(sunTimes, BDAstroCalc.sunSignificantTimes(date: Date().yesterday as NSDate, location: myLocationCoordinates))
        sun.phaseTitle = getSunPhaseTitle(sunLocation.altitude * radiansToDegrees)
        
        let sunCoordinates = BDAstroCalc.sunCoordinates(daysSinceJan12000: Jan12000Date)
        sun.declination = declinationToString(sunCoordinates.declination * radiansToDegrees)
        sun.rightAscension = String(format: "%3.1f", sunCoordinates.rightAscension  * radiansToDegrees)
        sun.zodiacSign = getZodiacSign(sunCoordinates.rightAscension * radiansToDegrees)
        
        DispatchQueue.main.async {
            self.delegate?.sunDataReady(sun: self.sun)
        }
    }
    
    open func getOldSunData() -> GpsSunInfoModel {
        return sun
    }
    
    //MARK: - Support functions for sun data
    
    ///Function that return the today number of hours of sun lyght
    private func getTodayDaylightHours(_ today: [String : NSDate], _ yesterday: [String : NSDate]) -> String {
        let todayTime = getDaylightHoursDifference(today["sunsetEnd"]! as Date, today["sunriseStart"]! as Date)
        let yesterdayTime = getDaylightHoursDifference(yesterday["sunsetEnd"]! as Date, yesterday["sunriseStart"]! as Date)
        if let t = todayTime.toDate(format: "HH:mm:ss"), let y = yesterdayTime.toDate(format: "HH:mm:ss") {
            if(t.isGreaterThan(y)) {
                return todayTime + " (+" + getDaylightHoursDifference(t, y) + ")"
            } else {
                return todayTime + " (-" + getDaylightHoursDifference(t, y) + ")"
            }
        } else {
            return todayTime
        }
    }
    
    ///Function that return the deffirence of minutes of sun lyght of today and yesterday
    private func getDaylightHoursDifference(_ sunrise: Date, _ sunset: Date) -> String {
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
    
    ///Function that return the sun phase name based on the sun altitude (positive or negative) in the sky
    private func getSunPhaseTitle(_ altitude: Double) -> String {
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
