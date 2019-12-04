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
import SwifterSwift

public protocol MRGpsDataGetterSunDataDelegate: NSObjectProtocol {
    func sunDataReady(sun: GpsSunInfoModel)
}

open class SunDataGetter: NSObject {
    
    public static let shared = SunDataGetter()
    open weak var delegate: MRGpsDataGetterSunDataDelegate?
    
    let sun = GpsSunInfoModel()
    
    
    /// Function that start to retrive all Sun data based on a specified location
    /// - Parameter currentLocation: location
    open func getSunInfo(currentLocation: CLLocation) {
        DispatchQueue.global().async {
            self.reverseSolarInfo(currentLocation)
        }
    }
    
    /// Private function that start to retrive all Sun data based on a specified location
    /// - Parameter currentLocation: location
    private func reverseSolarInfo(_ currentLocation: CLLocation){
        var timeFormat = "HH:mm:ss"
        if Bool(Preferences.shared.getPreference("minutesTimes"))! == true {
            timeFormat = "HH:mm"
        }
        
        let myLocationCoordinates = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let Jan12000Date = BDAstroCalc.daysSinceJan12000(date: NSDate())
        
        let sunRiseSet = BDAstroCalc.sunRiseAndSet(date: NSDate(), location: myLocationCoordinates)
        sun.solarNoon = (sunRiseSet.solarNoon as Date).string(withFormat: timeFormat)
        sun.nadir = (sunRiseSet.nadir as Date).string(withFormat: timeFormat)
        
        let sunLocation = BDAstroCalc.sunPosition(date: NSDate(), location: myLocationCoordinates)
        let azim = (sunLocation.azimuth + Double.pi).radiansToDegrees
        sun.altitude = String(format: "%3.1f", sunLocation.altitude.radiansToDegrees) + loc("DEGREE")
        sun.azimuth = String(format: "%3.1f", azim) + loc("DEGREE") + " " + getAngleName(azim)
        
        let sunTimes = BDAstroCalc.sunSignificantTimes(date: NSDate(), location: myLocationCoordinates)
        sun.astronomicalDuskSunrise = (sunTimes["nightEnd"]! as Date).string(withFormat: timeFormat)
        sun.nauticalDuskSunrise = (sunTimes["nauticalDawn"]! as Date).string(withFormat: timeFormat)
        sun.civilDuskSunrise = (sunTimes["dawn"]! as Date).string(withFormat: timeFormat)
        sun.sunriseStart = (sunTimes["sunriseStart"]! as Date).string(withFormat: timeFormat)
        sun.sunriseEnd = (sunTimes["sunriseEnd"]! as Date).string(withFormat: timeFormat)
        sun.sunsetStart = (sunTimes["sunsetStart"]! as Date).string(withFormat: timeFormat)
        sun.sunsetEnd = (sunTimes["sunsetEnd"]! as Date).string(withFormat: timeFormat)
        sun.civilDuskSunset = (sunTimes["dusk"]! as Date).string(withFormat: timeFormat)
        sun.nauticalDuskSunset = (sunTimes["nauticalDusk"]! as Date).string(withFormat: timeFormat)
        sun.astronomicalDuskSunset = (sunTimes["nightStart"]! as Date).string(withFormat: timeFormat)
        
        sun.blueHourSunriseStart = (sunTimes["dawn"]! as Date).string(withFormat: timeFormat)
        sun.blueHourSunriseEnd = ((sunTimes["dawn"]! as Date).plusMinutes((Date().minutesBetween(date1: (sunTimes["dawn"]! as Date), date2: (sunTimes["sunriseStart"]! as Date))/2))).string(withFormat: timeFormat)
        sun.blueHourSunsetStart = ((sunTimes["sunsetEnd"]! as Date).plusMinutes((Date().minutesBetween(date1: (sunTimes["sunsetEnd"]! as Date), date2: (sunTimes["dusk"]! as Date))/2))).string(withFormat: timeFormat)
        sun.blueHourSunsetEnd = (sunTimes["dusk"]! as Date).string(withFormat: timeFormat)

        sun.goldenHourSunriseStart = ((sunTimes["dawn"]! as Date).plusMinutes((Date().minutesBetween(date1: (sunTimes["dawn"]! as Date), date2: (sunTimes["sunriseStart"]! as Date))/2))).string(withFormat: timeFormat)
        sun.goldenHourSunriseEnd = (sunTimes["goldenHourEnd"]! as Date).string(withFormat: timeFormat)
        sun.goldenHourSunsetStart = (sunTimes["goldenHourStart"]! as Date).string(withFormat: timeFormat)
        sun.goldenHourSunsetEnd = ((sunTimes["sunsetEnd"]! as Date).plusMinutes((Date().minutesBetween(date1: (sunTimes["sunsetEnd"]! as Date), date2: (sunTimes["dusk"]! as Date))/2))).string(withFormat: timeFormat)
        
        sun.daylightHours = getTodayDaylightHours(sunTimes, BDAstroCalc.sunSignificantTimes(date: Date().yesterday as NSDate, location: myLocationCoordinates))
        sun.phaseTitle = getSunPhaseTitle(sunLocation.altitude.radiansToDegrees)
        
        let sunCoordinates = BDAstroCalc.sunCoordinates(daysSinceJan12000: Jan12000Date)
        sun.declination = declinationToString(sunCoordinates.declination.radiansToDegrees)
        sun.rightAscension = String(format: "%3.1f", sunCoordinates.rightAscension.radiansToDegrees)
        sun.zodiacSign = getSunZodiacSign(sunCoordinates.rightAscension.radiansToDegrees)
        
        
        DispatchQueue.main.async {
            self.delegate?.sunDataReady(sun: self.sun)
        }
    }
    
    /// Get the sun data object
    open func getOldSunData() -> GpsSunInfoModel {
        return sun
    }
    
    //MARK: - Support functions for sun data
    
    /// Function that return the today sun lyght hours and the difference of minutes of sun lyght of today and yesterday
    /// - Parameters:
    ///   - today: today sun info
    ///   - yesterday: yesterday date info
    private func getTodayDaylightHours(_ today: [String : NSDate], _ yesterday: [String : NSDate]) -> String {
        let todayTime = getDaylightHoursDifference(today["sunriseStart"]! as Date, today["sunsetEnd"]! as Date)
        let yesterdayTime = getDaylightHoursDifference(yesterday["sunriseStart"]! as Date, yesterday["sunsetEnd"]! as Date)
        if let t = todayTime.date(withFormat: "HH:mm:ss"), let y = yesterdayTime.date(withFormat: "HH:mm:ss") {
            let diff = getDaylightHoursDifference(t, y).split(separator: ":")
            if(t.timeIntervalSince(y) > 0) {
                return todayTime + " (+" + diff[1] + ":" + diff[2] + ")"
            } else {
                return todayTime + " (-" + diff[1] + ":" + diff[2] + ")"
            }
        } else {
            return todayTime
        }
    }
    
    /// Function that return the difference of minutes of sun lyght of today and yesterday
    /// - Parameters:
    ///   - sunrise: the sunrise date and time
    ///   - sunset: the sunset date and time
    private func getDaylightHoursDifference(_ sunrise: Date, _ sunset: Date) -> String {
        let difference = sunset.timeIntervalSince(sunrise)
        return difference.stringFromTimeInterval()
    }
    
    /// Function that return the sun phase name based on the sun altitude (positive or negative) in the sky
    /// - Parameter altitude: altitude on the sun (in degrees)
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
        return loc("NOTAVAILABLENUMBER")
    }
    
//    private func getSun() -> [Double] {
//        var t: Double = 0, slongitude: Double = 0, sanomaly: Double = 0
//
//        // SUN PARAMETERS (Formulae from "Calendrical Calculations")
//        let lon: Double = (280.46645 + 36000.76983 * t + 0.0003032 * t * t)
//        let anom: Double = (357.5291 + 35999.0503 * t - 0.0001559 * t * t - 4.8E-07 * t * t * t)
//        sanomaly = anom * (1.0 / 180.0 / Double.pi) //SunMoonCalculator.DEG_TO_RAD
//        var c: Double = (1.9146 - 0.004817 * t - 0.000014 * t * t) * sin(sanomaly)
//        c = c + (0.019993 - 0.000101 * t) * sin(2 * sanomaly)
//        c = c + 0.00029 * sin(3.0 * sanomaly) // Correction to the mean ecliptic longitude
//
//        // Now, let calculate nutation and aberration
//        let M1: Double = (124.90 - 1934.134 * t + 0.002063 * t * t) * (1.0 / 180.0 / Double.pi)
//        let M2: Double = (201.11 + 72001.5377 * t + 0.00057 * t * t) * (1.0 / 180.0 / Double.pi)
//        let d: Double = -0.00569 - 0.0047785 * sin(M1) - 0.0003667 * sin(M2)
//
//        slongitude = lon + c + d // apparent longitude (error<0.003 deg)
//        let slatitude: Double = 0 // Sun's ecliptic latitude is always negligible
//        let ecc: Double = 0.016708617 - 4.2037E-05 * t - 1.236E-07 * t * t // Eccentricity
//        let v: Double = sanomaly + c * (1.0 / 180.0 / Double.pi) // True anomaly
//        let sdistance: Double = 1.000001018 * (1.0 - ecc * ecc) / (1.0 + ecc * cos(v)) // In UA
//
//        return [slongitude, slatitude, sdistance, atan(696000 / (149597870.691 * sdistance))]
//    }
    
    /// Function that return the zodiac sign of sun/moon based on the right ascension
    /// - Parameter rightAscension: the right asnension of Sun/Moon (in radians).
    private func getSunZodiacSign(_ rightAscension: Double) -> String {
//        var rightAscension = Double((rightAscension + 360).int % 360)
//        if(rightAscension < 0) {
//            rightAscension = -1 * rightAscension
//        }
//        var zodiacSign = loc("NOTAVAILABLENUMBER")
//        if (rightAscension < 33.18) {
//            zodiacSign = loc("position_ARIETETITLE")
//        } else if (rightAscension < 51.16) {
//            zodiacSign = loc("position_TOROTITLE")
//        } else if (rightAscension < 93.44) {
//            zodiacSign = loc("position_GEMELLITITLE")
//        } else if (rightAscension < 119.48) {
//            zodiacSign = loc("position_CANCROTITLE")
//        } else if (rightAscension < 135.30) {
//            zodiacSign = loc("position_LEONETITLE")
//        } else if (rightAscension < 173.34) {
//            zodiacSign = loc("position_VERGINETITLE")
//        } else if (rightAscension < 224.17) {
//            zodiacSign = loc("position_BILANCIATITLE")
//        } else if (rightAscension < 242.57) {
//            zodiacSign = loc("position_SCORPIOTITLE")
//        } else if (rightAscension < 271.26) {
//            zodiacSign = loc("position_SAGITTARIOTITLE")
//        } else if (rightAscension < 302.49) {
//            zodiacSign = loc("position_CAPRICTITLE")
//        } else if (rightAscension < 311.72) {
//            zodiacSign = loc("position_ACQUARIOTITLE")
//        } else if (rightAscension < 348.58) {
//            zodiacSign = loc("position_PESCITITLE")
//        } else {
//            zodiacSign = loc("position_ARIETETITLE")
//        }
        
        var rightAscension = (rightAscension + 360).int % 360
        if(rightAscension < 0) {
            rightAscension = -1 * rightAscension
        }
        var zodiacSign = loc("NOTAVAILABLENUMBER")
        switch rightAscension {
            case 0..<30: zodiacSign = loc("position_PESCITITLE")
            case 30..<60: zodiacSign = loc("position_ARIETETITLE")
            case 60..<90: zodiacSign = loc("position_TOROTITLE")
            case 90..<120: zodiacSign = loc("position_GEMELLITITLE")
            case 120..<150: zodiacSign = loc("position_CANCROTITLE")
            case 150..<180: zodiacSign = loc("position_LEONETITLE")
            case 180..<210: zodiacSign = loc("position_VERGINETITLE")
            case 210...240: zodiacSign = loc("position_BILANCIATITLE")
            case 240...270: zodiacSign = loc("position_SCORPIOTITLE")
            case 270...300: zodiacSign = loc("position_SAGITTARIOTITLE")
            case 300...330: zodiacSign = loc("position_CAPRICTITLE")
            case 330...360: zodiacSign = loc("position_ACQUARIOTITLE")
            default: break
        }
        return zodiacSign
    }
    
}
