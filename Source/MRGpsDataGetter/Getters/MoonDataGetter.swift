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
    func moonDataReady(moon: GpsMoonInfoModel)
}

open class MoonDataGetter: NSObject {
    
    public static let shared = MoonDataGetter()
    open weak var delegate : MRGpsDataGetterMoonDataDelegate?
    
    let moon = GpsMoonInfoModel()
    
    
    /// Function that start to retrive all Moon data based on a specified location
    /// - Parameter currentLocation: location
    open func getMoonInfo(currentLocation: CLLocation){
        DispatchQueue.global().async {
            self.reverseMoonInfo(currentLocation)
        }
    }
    
    /// Private function that start to retrive all Moon data based on a specified location
    /// - Parameter currentLocation: location
    private func reverseMoonInfo(_ currentLocation: CLLocation){
        var timeFormat = "HH:mm:ss"
        if Bool(Preferences.shared.getPreference("minutesTimes"))! == true {
            timeFormat = "HH:mm"
        }
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
        moon.phaseTitle = getMoonPhaseTitle(moonPhase.phase)
        moon.phaseIcon = getMoonPhaseIcon(moonPhase.phase)
        moon.phaseAngle = String(format: "%3.1f", moonPhase.angle.radiansToDegrees)
        
        let moonCoordinates = BDAstroCalc.moonCoordinates(daysSinceJan12000: Jan12000Date)
        moon.declination = declinationToString(moonCoordinates.declination.radiansToDegrees)
        moon.rightAscension = String(format: "%3.1f", moonCoordinates.rightAscension.radiansToDegrees)
        moon.zodiacSign = getMoonZodicaSign(date: Date())//getZodiacSign(moonCoordinates.rightAscension.radiansToDegrees)
        moon.age = getMoonAge(date: Date()).string
        
        let moonTilt = BDAstroCalc.moonTilt(date: NSDate(), location: myLocationCoordinates)
        moon.moonTilt = moonTilt.diff.string
        
        
        DispatchQueue.main.async {
            self.delegate?.moonDataReady(moon: self.moon)
        }
    }
    
    /// Get the moon data object
    open func getOldMoonData() -> GpsMoonInfoModel {
        return moon
    }
    
    //MARK: - Support functions for moon data
    
    /// Function that return the visibility of the moon in sky (if it is under or hover the horizon)
    /// - Parameter altitude: altitude on the moon (in degrees)
    private func getMoonVisibility(_ altitude: Double) -> String {
        if (altitude >= 0) {
            return loc("positionPhone_POSITIONMOONPOSITIVETITLE")
        }
        if (altitude < 0) {
            return loc("positionPhone_POSITIONMOONNEGATIVETITLE")
        }
        return loc("NOTAVAILABLENUMBER")
    }
    
    /// Function that return the moon phase name based on the moon phase angle (is the midpoint of the illuminated limb of the moon going east)
    /// - Parameter phase: the phase is a number from 0 to 1, where 0 and 1 are a new moon, 0.5 is a full moon, 0 - 0.5 is waxing, and 0.5 - 1.0 is waning
    private func getMoonPhaseTitle(_ phase: Double) -> String {
        if phase >= 0 && phase <= 0.03448275862 { return loc("position_NEWMOONTITLE") }
        if phase > 0.03448275862 && phase <= 0.06896551724 { return loc("position_UPMOONTITLE") }
        if phase > 0.06896551724 && phase <= 0.10344827586 { return loc("position_UPMOONTITLE") }
        if phase > 0.10344827586 && phase <= 0.13793103448 { return loc("position_UPMOONTITLE") }
        if phase > 0.13793103448 && phase <= 0.1724137931 { return loc("position_UPMOONTITLE") }
        if phase > 0.1724137931 && phase <= 0.20689655172 { return loc("position_UPMOONTITLE") }
        if phase > 0.20689655172 && phase <= 0.24137931034 { return loc("position_UPMOONTITLE") }
        if phase > 0.24137931034 && phase <= 0.27586206896 { return loc("position_FIRSTMOONTITLE") }
        if phase > 0.27586206896 && phase <= 0.31034482758 { return loc("position_GIBUPMOONTITLE") }
        if phase > 0.31034482758 && phase <= 0.3448275862 { return loc("position_GIBUPMOONTITLE") }
        if phase > 0.3448275862 && phase <= 0.37931034482 { return loc("position_GIBUPMOONTITLE") }
        if phase > 0.37931034482 && phase <= 0.41379310344 { return loc("position_GIBUPMOONTITLE") }
        if phase > 0.41379310344 && phase <= 0.44827586206 { return loc("position_GIBUPMOONTITLE") }
        if phase > 0.44827586206 && phase <= 0.48275862068 { return loc("position_GIBUPMOONTITLE") }
        if phase > 0.48275862068 && phase <= 0.5172413793 { return loc("position_FULLMOONTITLE") }
        if phase > 0.5172413793 && phase <= 0.55172413792 { return loc("position_GIPDOWNMOONTITLE") }
        if phase > 0.55172413792 && phase <= 0.58620689654 { return loc("position_GIPDOWNMOONTITLE") }
        if phase > 0.58620689654 && phase <= 0.62068965516 { return loc("position_GIPDOWNMOONTITLE") }
        if phase > 0.62068965516 && phase <= 0.65517241378 { return loc("position_GIPDOWNMOONTITLE") }
        if phase > 0.65517241378 && phase <= 0.6896551724 { return loc("position_GIPDOWNMOONTITLE") }
        if phase > 0.6896551724 && phase <= 0.72413793102 { return loc("position_GIPDOWNMOONTITLE") }
        if phase > 0.72413793102 && phase <= 0.75862068964 { return loc("position_LASTMOONTITLE") }
        if phase > 0.75862068964 && phase <= 0.79310344826 { return loc("position_DOWNMOONTITLE") }
        if phase > 0.79310344826 && phase <= 0.82758620688 { return loc("position_DOWNMOONTITLE") }
        if phase > 0.82758620688 && phase <= 0.8620689655 { return loc("position_DOWNMOONTITLE") }
        if phase > 0.8620689655 && phase <= 0.89655172412 { return loc("position_DOWNMOONTITLE") }
        if phase > 0.89655172412 && phase <= 0.93103448274 { return loc("position_DOWNMOONTITLE") }
        if phase > 0.93103448274 && phase <= 0.96551724136 { return loc("position_DOWNMOONTITLE") }
        if phase > 0.96551724136 && phase <= 1 { return loc("position_NEWMOONTITLE") }
        return loc("NOTAVAILABLENUMBER")
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
    
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    //Получить знак зодиака для луны
    public func getMoonZodicaSign(date: Date) -> String {
        var longitude: Double = 0.0
        var zodiac: String

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
            zodiac = "aries"
        } else if (longitude < 51.16) {
            zodiac = "cancer"
        } else if (longitude < 93.44) {
            zodiac = "gemini"
        } else if (longitude < 119.48) {
            zodiac = "cancer"
        } else if (longitude < 135.30) {
            zodiac = "leo"
        } else if (longitude < 173.34) {
            zodiac = "virgo"
        } else if (longitude < 224.17) {
            zodiac = "libra"
        } else if (longitude < 242.57) {
            zodiac = "scorpio"
        } else if (longitude < 271.26) {
            zodiac = "sagittarius"
        } else if (longitude < 302.49) {
            zodiac = "capricorn"
        } else if (longitude < 311.72) {
            zodiac = "aquarius"
        } else if (longitude < 348.58) {
            zodiac = "pisces"
        } else {
            zodiac = "aries"
        }

        return zodiac
    }
    
    //Получить фазу луны
       private func getMoonPhaseTitle(date: Date) -> String {
           let age: Double = self.getMoonAge(date: date)

           var phase: String

           if (age < 1.84566) {
               phase = "newMoon"
           } else if (age < 5.53699) {
               phase = "waxingCrescent"
           } else if (age < 9.22831) {
               phase = "firstQuarter"
           } else if (age < 12.91963) {
               phase = "waxingGibbous"
           } else if (age < 16.61096) {
               phase = "fullMoon"
           } else if (age < 20.30228) {
               phase = "waningGibbous"
           } else if (age < 23.99361) {
               phase = "lastQuarter"
           } else if (age < 27.68493) {
               phase = "waningCrescent"
           } else {
               phase = "newMoon"
           }

           return phase
       }

       //Получить лунный день
       private func getMoonAge(date: Date) -> Double {
           var age: Double = 0.0

           var yy: Double = 0.0
           var mm: Double = 0.0
           var k1: Double = 0.0
           var k2: Double = 0.0
           var k3: Double = 0.0
           var jd: Double = 0.0
           var ip: Double = 0.0

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
           age = ip * 29.53

           return age
       }

       //Получить знак зодиака для дуны, траекторию луны, фазу луны
       private func getMoonTrajectory(date: Date) -> String {
           let age: Double = self.getMoonAge(date: date)
           var trajectory: String


           if (age < 1.84566) {
               trajectory = "ascendent"
           } else if (age < 5.53699) {
               trajectory = "ascendent"
           } else if (age < 9.22831) {
               trajectory = "ascendent"
           } else if (age < 12.91963) {
               trajectory = "ascendent"
           } else if (age < 16.61096) {
               trajectory = "descendent"
           } else if (age < 20.30228) {
               trajectory = "descendent"
           } else if (age < 23.99361) {
               trajectory = "descendent"
           } else if (age < 27.68493) {
               trajectory = "descendent"
           } else {
               trajectory = "ascendent"
           }

           return trajectory
       }
    
    //нормализовать число, т.е. число от 0 до 1
    private func normalize(_ value: Double) -> Double {
        var v = value - floor(value)
        if (v < 0) {
            v = v + 1
        }
        return v
    }
    
}
