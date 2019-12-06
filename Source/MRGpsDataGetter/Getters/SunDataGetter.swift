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
    func sunDataReady(sun: SunInfoModel)
}

open class SunDataGetter: NSObject {
    
    public static let shared = SunDataGetter()
    open weak var delegate: MRGpsDataGetterSunDataDelegate?
    
    let sun = SunInfoModel()
    
    
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
        sun.zodiacSign = getZodiacSign(sunCoordinates.rightAscension.radiansToDegrees)
        
        sun.previusEclipse = EclipseCalculator().getEclipseFor(date: Date(), eclipseType: .Solar, next: false)
        sun.nextEclipse = EclipseCalculator().getEclipseFor(date: Date(), eclipseType: .Solar, next: true)
        
        
        
        /////////////////////////////
        do {
            let smc:SunMoonCalculator = try SunMoonCalculator(date: Date(), longitude: currentLocation.coordinate.longitude, latitude: currentLocation.coordinate.latitude)
            smc.calcSunAndMoon()
            sun.distance = smc.sunDistance.string + loc("AUs")
            sun.transit = smc.sunTransit.string
            sun.transitElevation = String(format: "%3.1f", smc.sunTransitElevation.radiansToDegrees) + loc("DEGREE")
        } catch {
            debugPrint("Failure!!!")
        }
        /////////////////////////////
        
        
        DispatchQueue.main.async {
            self.delegate?.sunDataReady(sun: self.sun)
        }
    }
    
    /// Get the sun data object
    open func getOldSunData() -> SunInfoModel {
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
            return loc("DAY")
        }
        if (altitude <= 0 && altitude >= -6) {
            return loc("CREPCIVSUNRISE")
        }
        if (altitude < -6 && altitude >= -12) {
            return loc("CREPNAUTICSUNRISE")
        }
        if (altitude < -12 && altitude >= -18) {
            return loc("CREPASTROSUNRISE")
        }
        if (altitude < -18) {
            return loc("NIGHT")
        }
        return loc("NOTAVAILABLENUMBER")
    }
    
}
