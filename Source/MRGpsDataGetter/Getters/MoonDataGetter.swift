//
//  MoonDataGetter.swift
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

public protocol MRGpsDataGetterMoonDataDelegate: NSObjectProtocol {
    func moonDataReady(moon: MoonInfoModel)
}

open class MoonDataGetter: NSObject {
    
    public static let shared = MoonDataGetter()
    open weak var delegate : MRGpsDataGetterMoonDataDelegate?
    
    let moon = MoonInfoModel()
    
    
    /// Function that start to retrive all Moon data based on a specified location
    /// - Parameter currentLocation: location
    open func getMoonInfo(currentLocation: CLLocation){
        reverseMoonInfo(currentLocation)
    }
    
    /// Private function that start to retrive all Moon data based on a specified location
    /// - Parameter currentLocation: location
    private func reverseMoonInfo(_ currentLocation: CLLocation){
        var timeFormat = "HH:mm:ss"
        if Bool(Preferences.shared.getPreference("minutesTimes"))! == true {
            timeFormat = "HH:mm"
        }

        //BDAstroCalc
        let myLocationCoordinates = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let Jan12000Date = BDAstroCalc.daysSinceJan12000(date: NSDate())
        
        let moonRiseSet = BDAstroCalc.moonRiseAndSet(date: NSDate(), location: myLocationCoordinates)
        moon.moonRise = (moonRiseSet.rise).string(withFormat: timeFormat)
        moon.moonSet = (moonRiseSet.set).string(withFormat: timeFormat)
        
        let moonLocation = BDAstroCalc.moonPosition(date: NSDate(), location: myLocationCoordinates)
        let azim = ((moonLocation.azimuth + Double.pi).radiansToDegrees).truncatingRemainder(dividingBy: 360)
        moon.altitude = String(format: "%3.1f", moonLocation.altitude.radiansToDegrees) + loc("DEGREE")
        moon.azimuth = String(format: "%3.1f", azim) + loc("DEGREE") + " " + getAngleName(azim)
        moon.distance = "\(Int(moonLocation.distance).formattedWithSeparator) " + loc("KILOMETERS")
        moon.horizontalPosition = getMoonVisibility(moonLocation.altitude.radiansToDegrees)
        
        let moonPhase = BDAstroCalc.moonPhase(date: NSDate())
        moon.fractionOfMoonIlluminated = String(format: "%3.1f", moonPhase.fractionOfMoonIlluminated * 100) + " " + loc("PERCENT")
        moon.phase = moonPhase.phase.string
        moon.phaseIcon = getMoonPhaseIcon(moonPhase.phase)
        moon.phaseAngle = String(format: "%3.1f", moonPhase.angle.radiansToDegrees)
        
        let moonCoordinates = BDAstroCalc.moonCoordinates(daysSinceJan12000: Jan12000Date)
        moon.declination = declinationToString(moonCoordinates.declination.radiansToDegrees)
        moon.rightAscension = String(format: "%3.1f", moonCoordinates.rightAscension.radiansToDegrees)
        moon.moonTilt = moonTilt(date: NSDate(), location: myLocationCoordinates).diff.string

        moon.zodiacSign = getMoonZodicaSign(Date())

        //AstrologyCalc
        moon.previusEclipse = EclipseCalculator().getEclipseFor(date: Date(), eclipseType: .Lunar, next: false)
        moon.nextEclipse = EclipseCalculator().getEclipseFor(date: Date(), eclipseType: .Lunar, next: true)
        
        //SunMoonCalculator
        do {
            let smc: SunMoonCalculator = try SunMoonCalculator(date: Date(), longitude: currentLocation.coordinate.longitude, latitude: currentLocation.coordinate.latitude)
            smc.calcSunAndMoon()
            
            moon.moonRise = getDateFrom(try SunMoonCalculator.getDate(jd: smc.moonRise)).string(withFormat: timeFormat)
            moon.moonSet = getDateFrom(try SunMoonCalculator.getDate(jd: smc.moonSet)).string(withFormat: timeFormat)
 
            moon.altitude = String(format: "%3.1f", smc.moonElevation.radiansToDegrees) + loc("DEGREE")
            moon.azimuth = String(format: "%3.1f", smc.moonAzimuth.radiansToDegrees) + loc("DEGREE") + " " + getAngleName(smc.moonAzimuth.radiansToDegrees)
            moon.distance = "\(Int(smc.moonDistance * SunMoonCalculator.AU).formattedWithSeparator) " + loc("KILOMETERS")
            
            moon.fractionOfMoonIlluminated = String(format: "%3.1f", smc.moonIllumination * 100) + " " + loc("PERCENT")
            moon.phaseTitle = smc.moonPhase
            
            moon.moonNoon = getDateFrom(try SunMoonCalculator.getDate(jd: smc.moonTransit)).minusHours(12).string(withFormat: timeFormat)
            moon.nadir = getDateFrom(try SunMoonCalculator.getDate(jd: smc.moonTransit)).string(withFormat: timeFormat)
            moon.trajectory = getMoonTrajectoryFromAge(smc.moonAge, Date())

            if smc.moonAge < 2 {
                moon.age = String(format: "%3.1f", smc.moonAge) + " " + loc("DAY")
            } else {
                moon.age = String(format: "%3.1f", smc.moonAge) + " " + loc("DAYS")
            }
        } catch {
            debugPrint("Failure in SunMoonCalculator (moon)")
        }
        
        
        DispatchQueue.main.async {
            self.delegate?.moonDataReady(moon: self.moon)
        }
    }
    
    /// Get the moon data object
    open func getOldMoonData() -> MoonInfoModel {
        return moon
    }
    
    //MARK: - Support functions for moon data
    
    /// Function that return the visibility of the moon in sky (if it is under or hover the horizon)
    /// - Parameter altitude: altitude on the moon (in degrees)
    private func getMoonVisibility(_ altitude: Double) -> String {
        if (altitude >= 0) {
            return loc("POSITIONMOON_POSITIVE")
        }
        if (altitude < 0) {
            return loc("POSITIONMOON_NEGATIVE")
        }
        return loc("NOTAVAILABLENUMBER")
    }
    
    /// The moon tilt angle with the help of BDAstroCalc library. The slope angle of the observed moon-sun line (α) and slope angle of the expected moon-sun line (β).
    /// - Parameters:
    ///   - date: a date
    ///   - location: a location. Requires CLLocationCoordinate2D to reduce confusion, as these are in degrees while other methods require radians
    private func moonTilt(date: NSDate, location: CLLocationCoordinate2D) -> (tanAlfa: Double, tanBeta: Double, diff: Double) {
        
        let moonAltitude = BDAstroCalc.moonPosition(date: date, location: location).altitude
        let moonAzimuth = BDAstroCalc.moonPosition(date: date, location: location).azimuth
        let moonPhase = BDAstroCalc.moonPhase(date: date).phase
        let sunAltitude = BDAstroCalc.sunPosition(date: date, location: location).altitude
        let sunAzimuth = BDAstroCalc.sunPosition(date: date, location: location).azimuth

        let absAzimMoonSun = abs(sunAzimuth - moonAzimuth)
        let tanAlfa = ((cos(moonAltitude) * tan(sunAltitude)) - (sin(moonAltitude) * cos(absAzimMoonSun))) / sin(absAzimMoonSun)
        let tanBeta = (sin(moonAltitude) - sin(sunAltitude)) / (cos(sunAltitude) * sin(absAzimMoonSun))
        
        var diff = 0.0 //in radians
        if moonPhase <= 0.5 {
            if (absAzimMoonSun.radiansToDegrees) <= 180 {
                diff = atan(-tanAlfa)
            } else {
                diff = atan(tanAlfa)
            }
        } else {
            if (absAzimMoonSun.radiansToDegrees) <= 180 {
                diff = atan(tanAlfa)
            } else {
                diff = atan(-tanAlfa)
            }
        }

        return (tanAlfa, -tanBeta, diff)
    }
    
    /// Function that return the moon phase icon name based on the moon phase angle (is the midpoint of the illuminated limb of the moon going east)
    /// - Parameter phase: the phase is a number from 0 to 1, where 0 and 1 are a new moon, 0.5 is a full moon, 0 - 0.5 is waxing, and 0.5 - 1.0 is waning
    private func getMoonPhaseIcon(_ phase: Double) -> String {
        if phase >= 0 && phase <= 0.03448275862 { return "wi-moon-alt-new" }
        if phase > 0.03448275862 && phase <= 0.06896551724 { return "wi-moon-alt-waxing-crescent-1" }
        if phase > 0.06896551724 && phase <= 0.10344827586 { return "wi-moon-alt-waxing-crescent-2" }
        if phase > 0.10344827586 && phase <= 0.13793103448 { return "wi-moon-alt-waxing-crescent-3" }
        if phase > 0.13793103448 && phase <= 0.1724137931 { return "wi-moon-alt-waxing-crescent-4" }
        if phase > 0.1724137931 && phase <= 0.20689655172 { return "wi-moon-alt-waxing-crescent-5" }
        if phase > 0.20689655172 && phase <= 0.24137931034 { return "wi-moon-alt-waxing-crescent-6" }
        if phase > 0.24137931034 && phase <= 0.27586206896 { return "wi-moon-alt-first-quarter" }
        if phase > 0.27586206896 && phase <= 0.31034482758 { return "wi-moon-alt-waxing-gibbous-1" }
        if phase > 0.31034482758 && phase <= 0.3448275862 { return "wi-moon-alt-waxing-gibbous-2" }
        if phase > 0.3448275862 && phase <= 0.37931034482 { return "wi-moon-alt-waxing-gibbous-3" }
        if phase > 0.37931034482 && phase <= 0.41379310344 { return "wi-moon-alt-waxing-gibbous-4" }
        if phase > 0.41379310344 && phase <= 0.44827586206 { return "wi-moon-alt-waxing-gibbous-5" }
        if phase > 0.44827586206 && phase <= 0.48275862068 { return "wi-moon-alt-waxing-gibbous-6" }
        if phase > 0.48275862068 && phase <= 0.5172413793 { return "wi-moon-alt-full" }
        if phase > 0.5172413793 && phase <= 0.55172413792 { return "wi-moon-alt-waning-gibbous-1" }
        if phase > 0.55172413792 && phase <= 0.58620689654 { return "wi-moon-alt-waning-gibbous-2" }
        if phase > 0.58620689654 && phase <= 0.62068965516 { return "wi-moon-alt-waning-gibbous-3" }
        if phase > 0.62068965516 && phase <= 0.65517241378 { return "wi-moon-alt-waning-gibbous-4" }
        if phase > 0.65517241378 && phase <= 0.6896551724 { return "wi-moon-alt-waning-gibbous-5" }
        if phase > 0.6896551724 && phase <= 0.72413793102 { return "wi-moon-alt-waning-gibbous-6" }
        if phase > 0.72413793102 && phase <= 0.75862068964 { return "wi-moon-alt-third-quarter" }
        if phase > 0.75862068964 && phase <= 0.79310344826 { return "wi-moon-alt-waning-crescent-1" }
        if phase > 0.79310344826 && phase <= 0.82758620688 { return "wi-moon-alt-waning-crescent-2" }
        if phase > 0.82758620688 && phase <= 0.8620689655 { return "wi-moon-alt-waning-crescent-3" }
        if phase > 0.8620689655 && phase <= 0.89655172412 { return "wi-moon-alt-waning-crescent-4" }
        if phase > 0.89655172412 && phase <= 0.93103448274 { return "wi-moon-alt-waning-crescent-5" }
        if phase > 0.93103448274 && phase <= 0.96551724136 { return "wi-moon-alt-waning-crescent-6" }
        if phase > 0.96551724136 && phase <= 1 { return "wi-moon-alt-new" }
        return loc("NOTAVAILABLENUMBER")
    }
    
    /// Function that return the zodiac sign of moon from the moon age at the specified date
    /// - Parameter date: a date
    private func getMoonZodicaSign(_ date: Date) -> String {
        var longitude: Double = 0.0
        var zodiac: String = loc("NOTAVAILABLENUMBER")
        
        var yy: Double = 0.0
        var mm: Double = 0.0
        var k1: Double = 0.0
        var k2: Double = 0.0
        var k3: Double = 0.0
        var jd: Double = 0.0
        var ip: Double = 0.0
        var dp: Double = 0.0
        var rp: Double = 0.0
        
        let year: Double = Double(Calendar.current.component(.year, from: date))
        let month: Double = Double(Calendar.current.component(.month, from: date))
        let day: Double = Double(Calendar.current.component(.day, from: date))
        
        yy = year - floor((12 - month) / 10)
        mm = month + 9.0
        if (mm >= 12) {
            mm = mm - 12
        }
        
        k1 = floor(365.25 * (yy + 4712))
        k2 = floor(30.6 * mm + 0.5)
        k3 = floor(floor((yy / 100) + 49) * 0.75) - 38
        
        jd = k1 + k2 + day + 59
        if (jd > 2299160) {
            jd = jd - k3
        }
        
        ip = normalize((jd - 2451550.1) / 29.530588853)
        
        ip = ip * 2 * .pi
        
        dp = 2 * .pi * normalize((jd - 2451562.2) / 27.55454988)
        
        rp = normalize((jd - 2451555.8) / 27.321582241)
        longitude = 360 * rp + 6.3 * sin(dp) + 1.3 * sin(2 * ip - dp) + 0.7 * sin(2 * ip)
        
        if (longitude < 33.18) {
            zodiac = loc("ARIES")
        } else if (longitude < 51.16) {
            zodiac = loc("TAURUS")
        } else if (longitude < 93.44) {
            zodiac = loc("GEMINI")
        } else if (longitude < 119.48) {
            zodiac = loc("CANCER")
        } else if (longitude < 135.30) {
            zodiac = loc("LEO")
        } else if (longitude < 173.34) {
            zodiac = loc("VIRGO")
        } else if (longitude < 224.17) {
            zodiac = loc("LIBRA")
        } else if (longitude < 242.57) {
            zodiac = loc("SCORPIO")
        } else if (longitude < 271.26) {
            zodiac = loc("SAGITTARIUS")
        } else if (longitude < 302.49) {
            zodiac = loc("CAPRICORN")
        } else if (longitude < 311.72) {
            zodiac = loc("AQUARIUS")
        } else if (longitude < 348.58) {
            zodiac = loc("PESCES")
        } else {
            zodiac = loc("ARIES")
        }
        return zodiac
    }
    
    /// Function that return the moon trajectory from the moon age at the specified date
    /// - Parameter date: a date
    private func getMoonTrajectoryFromAge(_ moonAge: Double, _ date: Date) -> String {
        var trajectory: String = loc("NOTAVAILABLENUMBER")
        
        if (moonAge < 1.84566) {
            trajectory = loc("ASCENDENT")
        } else if (moonAge < 5.53699) {
            trajectory = loc("ASCENDENT")
        } else if (moonAge < 9.22831) {
            trajectory = loc("ASCENDENT")
        } else if (moonAge < 12.91963) {
            trajectory = loc("ASCENDENT")
        } else if (moonAge < 16.61096) {
            trajectory = loc("DESCENDENT")
        } else if (moonAge < 20.30228) {
            trajectory = loc("DESCENDENT")
        } else if (moonAge < 23.99361) {
            trajectory = loc("DESCENDENT")
        } else if (moonAge < 27.68493) {
            trajectory = loc("DESCENDENT")
        } else {
            trajectory = loc("ASCENDENT")
        }
        
        return trajectory
    }
    
    /// Function that normalize che value passed from parameter. Used in the moon's functions
    /// - Parameter value: the value to normalize
    private func normalize(_ value: Double) -> Double {
        var v = value - floor(value)
        if (v < 0) {
            v = v + 1
        }
        return v
    }
    
}
