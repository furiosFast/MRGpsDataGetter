//
//  SunDataGetter.swift
//  MRGpsDataGetter
//
//  Created by Marco Ricca on 20/11/2019
//  Copyright © 2019 Fast-Devs Project. All rights reserved.
//

import CoreLocation
import SwifterSwift
import UIKit

public protocol MRGpsDataGetterSunDataDelegate: NSObjectProtocol {
    func sunDataReady(sun: SunInfoModel)
}

open class SunDataGetter: NSObject {
    open weak var delegate: MRGpsDataGetterSunDataDelegate?

    let sun = SunInfoModel()

    /// Fetches all sun data for the given location.
    open func getSunInfo(currentLocation: CLLocation) {
        reverseSolarInfo(currentLocation)
    }

    private func reverseSolarInfo(_ currentLocation: CLLocation) {
        var timeFormat = "HH:mm:ss"
        if MRGpsDataGetter.shared.preferences.showMinutesInTimes {
            timeFormat = "HH:mm"
        }

        sun.timestamp = Date()

        let myLocationCoordinates = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let Jan12000Date = BDAstroCalc.daysSinceJan12000(date: NSDate())

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
        sun.blueHourSunriseEnd = (sunTimes["dawn"]! as Date).adding(.minute, value: ((sunTimes["dawn"]! as Date).minutesSince((sunTimes["sunriseStart"]! as Date)) / 2).int).string(withFormat: timeFormat)
        sun.blueHourSunsetStart = (sunTimes["sunsetEnd"]! as Date).adding(.minute, value: ((sunTimes["sunsetEnd"]! as Date).minutesSince((sunTimes["dusk"]! as Date)) / 2).int).string(withFormat: timeFormat)
        sun.blueHourSunsetEnd = (sunTimes["dusk"]! as Date).string(withFormat: timeFormat)

        sun.goldenHourSunriseStart = (sunTimes["dawn"]! as Date).adding(.minute, value: ((sunTimes["dawn"]! as Date).minutesSince((sunTimes["sunriseStart"]! as Date)) / 2).int).string(withFormat: timeFormat)
        sun.goldenHourSunriseEnd = (sunTimes["goldenHourEnd"]! as Date).string(withFormat: timeFormat)
        sun.goldenHourSunsetStart = (sunTimes["goldenHourStart"]! as Date).string(withFormat: timeFormat)
        sun.goldenHourSunsetEnd = (sunTimes["sunsetEnd"]! as Date).adding(.minute, value: ((sunTimes["sunsetEnd"]! as Date).minutesSince((sunTimes["dusk"]! as Date)) / 2).int).string(withFormat: timeFormat)

        sun.daylightHours = getTodayDaylightHours(sunTimes, BDAstroCalc.sunSignificantTimes(date: Date().yesterday as NSDate, location: myLocationCoordinates))

        let sunCoordinates = BDAstroCalc.sunCoordinates(daysSinceJan12000: Jan12000Date)
        sun.declination = declinationToString(sunCoordinates.declination.radiansToDegrees)
        sun.rightAscension = String(format: "%3.1f", sunCoordinates.rightAscension.radiansToDegrees)
        sun.zodiacSign = getSunZodiacSign(sunCoordinates.rightAscension.radiansToDegrees)

        // SunMoonCalculator
        do {
            let smc = try SunMoonCalculator(date: Date(), longitude: currentLocation.coordinate.longitude, latitude: currentLocation.coordinate.latitude)
            smc.calcSunAndMoon()
            sun.sunriseStart = try getDateFrom(SunMoonCalculator.getDate(jd: smc.sunRise)).string(withFormat: timeFormat)
            sun.sunsetStart = try getDateFrom(SunMoonCalculator.getDate(jd: smc.sunSet)).string(withFormat: timeFormat)
            sun.altitude = String(format: "%3.1f", smc.sunElevation.radiansToDegrees) + loc("DEGREE")
            sun.phaseTitle = getSunPhaseTitle(smc.sunElevation.radiansToDegrees)
            sun.horizontalPosition = getSunMoonVisibility(smc.sunElevation.radiansToDegrees, isSun: true)
            sun.azimuth = String(format: "%3.1f", smc.sunAzimuth.radiansToDegrees) + loc("DEGREE") + " " + getAngleName(smc.sunAzimuth.radiansToDegrees)
            sun.distance = String(format: "%3.4f", smc.sunDistance) + " " + loc("AUs")
            sun.solarNoon = try getDateFrom(SunMoonCalculator.getDate(jd: smc.sunTransit)).string(withFormat: timeFormat)
            sun.nadir = try getDateFrom(SunMoonCalculator.getDate(jd: smc.sunTransit)).adding(.hour, value: 12).string(withFormat: timeFormat)
        } catch {
            debugPrint("Failure in SunMoonCalculator (sun)")
        }

        DispatchQueue.main.async {
            self.delegate?.sunDataReady(sun: self.sun)
        }
    }

    /// Returns the last fetched sun data.
    open func getOldSunData() -> SunInfoModel {
        return sun
    }

    // MARK: - Support functions

    private func getTodayDaylightHours(_ today: [String: NSDate], _ yesterday: [String: NSDate]) -> String {
        let todayTime = getDaylightHoursDifference(today["sunriseStart"]! as Date, today["sunsetEnd"]! as Date)
        let yesterdayTime = getDaylightHoursDifference(yesterday["sunriseStart"]! as Date, yesterday["sunsetEnd"]! as Date)
        if let t = todayTime.date(withFormat: "HH:mm:ss"), let y = yesterdayTime.date(withFormat: "HH:mm:ss") {
            var timeFormat = "HH:mm:ss"
            if MRGpsDataGetter.shared.preferences.showMinutesInTimes {
                timeFormat = "HH:mm"
            }
            let diff = getDaylightHoursDifference(t, y).split(separator: ":")
            if t.timeIntervalSince(y) > 0 {
                return t.string(withFormat: timeFormat) + " (+ " + diff[1].replacingOccurrences(of: "-", with: "") + ":" + diff[2].replacingOccurrences(of: "-", with: "") + " s)"
            } else {
                return t.string(withFormat: timeFormat) + " (- " + diff[1].replacingOccurrences(of: "-", with: "") + ":" + diff[2].replacingOccurrences(of: "-", with: "") + " s)"
            }
        }
        return todayTime
    }

    private func getDaylightHoursDifference(_ sunrise: Date, _ sunset: Date) -> String {
        return sunset.timeIntervalSince(sunrise).stringFromTimeInterval()
    }

    private func getSunPhaseTitle(_ altitude: Double) -> String {
        if altitude > 0 { return loc("DAYLIGHT") }
        if altitude >= -6 { return loc("CREPCIVSUNRISE") }
        if altitude >= -12 { return loc("CREPNAUTICSUNRISE") }
        if altitude >= -18 { return loc("CREPASTROSUNRISE") }
        return loc("NIGHT")
    }

    private func getSunZodiacSign(_ rightAscension: Double) -> String {
        var ra = (Int(rightAscension) + 360) % 360
        if ra < 0 { ra = -ra }
        switch ra {
        case 0 ..< 30: return loc("PESCES")
        case 30 ..< 60: return loc("ARIES")
        case 60 ..< 90: return loc("TAURUS")
        case 90 ..< 120: return loc("GEMINI")
        case 120 ..< 150: return loc("CANCER")
        case 150 ..< 180: return loc("LEO")
        case 180 ..< 210: return loc("VIRGO")
        case 210 ..< 240: return loc("LIBRA")
        case 240 ..< 270: return loc("SCORPIO")
        case 270 ..< 300: return loc("SAGITTARIUS")
        case 300 ..< 330: return loc("CAPRICORN")
        case 330 ..< 360: return loc("AQUARIUS")
        default: return ""
        }
    }
}
