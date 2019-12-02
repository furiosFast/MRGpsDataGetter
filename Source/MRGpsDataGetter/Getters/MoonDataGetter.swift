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
        return loc("NOTAVAILABLENUMBER")
    }
    
    /// Function that return the moon phase name based on the moon phase angle (is the midpoint of the illuminated limb of the moon going east)
    /// - Parameter phase: the phase is a number from 0 to 1, where 0 and 1 are a new moon, 0.5 is a full moon, 0 - 0.5 is waxing, and 0.5 - 1.0 is waning
    private func getMoonPhaseTitle(_ phase: Double) -> String {
        if phase >= 0 && phase <= 0.111111111111111 { return loc("position_NEWMOONTITLE") }
        if phase > 0.111111111111111 && phase <= 0.222222222222222 { return loc("position_UPMOONTITLE") }
        if phase > 0.222222222222222 && phase <= 0.333333333333333 { return loc("position_FIRSTMOONTITLE") }
        if phase > 0.333333333333333 && phase <= 0.444444444444444 { return loc("position_GIBUPMOONTITLE") }
        if phase > 0.444444444444444 && phase <= 0.555555555555555 { return loc("position_FULLMOONTITLE") }
        if phase > 0.555555555555555 && phase <= 0.666666666666666 { return loc("position_GIPDOWNMOONTITLE") }
        if phase > 0.666666666666666 && phase <= 0.777777777777777 { return loc("position_LASTMOONTITLE") }
        if phase > 0.777777777777777 && phase <= 0.888888888888888 { return loc("position_DOWNMOONTITLE") }
        if phase > 0.888888888888888 && phase <= 1 { return loc("position_NEWMOONTITLE") }
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
    
}
