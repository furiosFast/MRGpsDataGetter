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
        moon.phaseTitle = getMoonPhaseTitle(moonPhase.phase)
        moon.phaseIcon = getMoonPhaseIcon(moonPhase.phase)
        moon.phaseAngle = String(format: "%3.1f", moonPhase.angle.radiansToDegrees)
        
        let moonCoordinates = BDAstroCalc.moonCoordinates(daysSinceJan12000: Jan12000Date)
        moon.declination = declinationToString(moonCoordinates.declination.radiansToDegrees)
        moon.rightAscension = String(format: "%3.1f", moonCoordinates.rightAscension.radiansToDegrees)
        moon.zodiacSign = getZodiacSign(moonCoordinates.rightAscension.radiansToDegrees)
        
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
        return loc("NOTAVAIABLENUMBER")
    }
    
    /// Function that return the moon phase name based on the moon phase angle (is the midpoint of the illuminated limb of the moon going east)
    /// - Parameter phase: the phase is a number from 0 to 1, where 0 and 1 are a new moon, 0.5 is a full moon, 0 - 0.5 is waxing, and 0.5 - 1.0 is waning
    private func getMoonPhaseTitle(_ phase: Double) -> String {
        if phase == 0 { return loc("position_NEWMOONTITLE") }
        if phase > 0 && phase < 0.25 { return loc("position_UPMOONTITLE") }
        if phase == 0.25 { return loc("position_FIRSTMOONTITLE") }
        if phase > 0.25 && phase < 0.5 { return loc("position_GIBUPMOONTITLE") }
        if phase == 0.5 { return loc("position_FULLMOONTITLE") }
        if phase > 0.5 && phase < 0.75 { return loc("position_GIPDOWNMOONTITLE") }
        if phase == 0.75 { return loc("position_LASTMOONTITLE") }
        if phase > 0.75 && phase < 1 { return loc("position_DOWNMOONTITLE") }
        if phase == 1 { return loc("position_NEWMOONTITLE") }
        return loc("NOTAVAIABLENUMBER")
    }
    
    /// Function that return the moon phase icon name based on the moon phase angle (is the midpoint of the illuminated limb of the moon going east)
    /// - Parameter phase: the phase is a number from 0 to 1, where 0 and 1 are a new moon, 0.5 is a full moon, 0 - 0.5 is waxing, and 0.5 - 1.0 is waning
    private func getMoonPhaseIcon(_ phase: Double) -> String {
        if phase == 0 { return "wi-moon-alt-new" }
        if phase > 0 && phase <= 0.04166666667 { return "wi-moon-alt-waxing-crescent-1" }
        if phase > 0.04166666667 && phase <= 0.08333333334 { return "wi-moon-alt-waxing-crescent-2" }
        if phase > 0.08333333334 && phase <= 0.12500000001 { return "wi-moon-alt-waxing-crescent-3" }
        if phase > 0.12500000001 && phase <= 0.16666666668 { return "wi-moon-alt-waxing-crescent-4" }
        if phase > 0.16666666668 && phase <= 0.20833333335 { return "wi-moon-alt-waxing-crescent-5" }
        if phase > 0.20833333335 && phase < 0.25 { return "wi-moon-alt-waxing-crescent-6" }
        if phase == 0.25 { return "wi-moon-alt-first-quarter" }
        if phase > 0.25 && phase <= 0.29166666669 { return "wi-moon-alt-waxing-gibbous-1" }
        if phase > 0.29166666669 && phase <= 0.33333333336 { return "wi-moon-alt-waxing-gibbous-2" }
        if phase > 0.33333333336 && phase <= 0.37500000003 { return "wi-moon-alt-waxing-gibbous-3" }
        if phase > 0.37500000003 && phase <= 0.4166666667 { return "wi-moon-alt-waxing-gibbous-4" }
        if phase > 0.4166666667 && phase <= 0.45833333337 { return "wi-moon-alt-waxing-gibbous-5" }
        if phase > 0.45833333337 && phase < 0.5 { return "wi-moon-alt-waxing-gibbous-6" }
        if phase == 0.5 { return "wi-moon-alt-full" }
        if phase > 0.5 && phase <= 0.54166666671 { return "wi-moon-alt-waning-gibbous-1" }
        if phase > 0.54166666671 && phase <= 0.58333333338 { return "wi-moon-alt-waning-gibbous-2" }
        if phase > 0.58333333338 && phase <= 0.62500000005 { return "wi-moon-alt-waning-gibbous-3" }
        if phase > 0.62500000005 && phase <= 0.66666666672 { return "wi-moon-alt-waning-gibbous-4" }
        if phase > 0.66666666672 && phase <= 0.70833333339 { return "wi-moon-alt-waning-gibbous-5" }
        if phase > 0.70833333339 && phase < 0.75 { return "wi-moon-alt-waning-gibbous-6" }
        if phase == 0.75 { return "wi-moon-alt-third-quarter" }
        if phase > 0.75 && phase <= 0.79166666673 { return "wi-moon-alt-waning-crescent-1" }
        if phase > 0.79166666673 && phase <= 0.8333333334 { return "wi-moon-alt-waning-crescent-2" }
        if phase > 0.8333333334 && phase <= 0.87500000007 { return "wi-moon-alt-waning-crescent-3" }
        if phase > 0.87500000007 && phase <= 0.91666666674 { return "wi-moon-alt-waning-crescent-4" }
        if phase > 0.91666666674 && phase <= 0.95833333341 { return "wi-moon-alt-waning-crescent-5" }
        if phase > 0.95833333341 && phase < 1 { return "wi-moon-alt-waning-crescent-6" }
        if phase == 1 { return "wi-moon-alt-new" }
        return loc("NOTAVAIABLENUMBER")
    }
    
}
