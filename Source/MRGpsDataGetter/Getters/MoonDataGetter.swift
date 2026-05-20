//
//  MoonDataGetter.swift
//  MRGpsDataGetter
//
//  Created by Marco Ricca on 20/11/2019
//  Copyright © 2019 Fast-Devs Project. All rights reserved.
//

import CoreLocation
import EKAstrologyCalc
import SwifterSwift
import UIKit

public protocol MRGpsDataGetterMoonDataDelegate: NSObjectProtocol {
    func moonDataReady(moon: MoonInfoModel)
}

open class MoonDataGetter: NSObject {
    open weak var delegate: MRGpsDataGetterMoonDataDelegate?

    let moon = MoonInfoModel()

    /// Fetches all moon data for the given location.
    open func getMoonInfo(currentLocation: CLLocation) {
        reverseMoonInfo(currentLocation)
    }

    private func reverseMoonInfo(_ currentLocation: CLLocation) {
        var timeFormat = "HH:mm:ss"
        if MRGpsDataGetter.shared.preferences.showMinutesInTimes {
            timeFormat = "HH:mm"
        }

        moon.timestamp = Date()

        let myLocationCoordinates = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let Jan12000Date = BDAstroCalc.daysSinceJan12000(date: NSDate())

        let moonPhase = BDAstroCalc.moonPhase(date: NSDate())
        moon.phase = moonPhase.phase.string
        moon.phaseIcon = getMoonPhaseIcon(moonPhase.phase)
        moon.phaseAngle = String(format: "%3.1f", moonPhase.angle.radiansToDegrees)

        let moonCoordinates = BDAstroCalc.moonCoordinates(daysSinceJan12000: Jan12000Date)
        moon.declination = declinationToString(moonCoordinates.declination.radiansToDegrees)
        moon.rightAscension = String(format: "%3.1f", moonCoordinates.rightAscension.radiansToDegrees)
        moon.moonTilt = moonTilt(date: NSDate(), location: myLocationCoordinates).diff.string

        // EKAstrologyCalc
        let ekac = EKAstrologyCalc(location: currentLocation).getInfo(date: Date())
        moon.zodiacSign = getMoonZodiacSignString(ekac.moonModels[0].sign)
        moon.previusEclipse = ekac.previousLunarEclipse
        moon.nextEclipse = ekac.nextLunarEclipse
        moon.trajectory = getMoonTrajectoryString(ekac.trajectory)

        // SunMoonCalculator
        do {
            let smc = try SunMoonCalculator(date: Date(), longitude: currentLocation.coordinate.longitude, latitude: currentLocation.coordinate.latitude)
            smc.calcSunAndMoon()

            moon.moonRise = try getDateFrom(SunMoonCalculator.getDate(jd: smc.moonRise)).string(withFormat: timeFormat)
            moon.moonSet = try getDateFrom(SunMoonCalculator.getDate(jd: smc.moonSet)).string(withFormat: timeFormat)
            moon.altitude = String(format: "%3.1f", smc.moonElevation.radiansToDegrees) + loc("DEGREE")
            moon.horizontalPosition = getSunMoonVisibility(smc.moonElevation.radiansToDegrees, isSun: false)
            moon.azimuth = String(format: "%3.1f", smc.moonAzimuth.radiansToDegrees) + loc("DEGREE") + " " + getAngleName(smc.moonAzimuth.radiansToDegrees)
            moon.distance = "\(Int(smc.moonDistance * SunMoonCalculator.AU).formattedWithSeparator) " + loc("KILOMETERS")
            moon.fractionOfMoonIlluminated = String(format: "%3.1f", smc.moonIllumination * 100) + " " + loc("PERCENT")
            moon.phaseTitle = smc.moonPhase
            moon.moonNoon = try getDateFrom(SunMoonCalculator.getDate(jd: smc.moonTransit)).string(withFormat: timeFormat)
            moon.nadir = try getDateFrom(SunMoonCalculator.getDate(jd: smc.moonTransit)).adding(.hour, value: -12).string(withFormat: timeFormat)

            if smc.moonAge < 2 {
                moon.age = smc.moonAge.int.string + " " + loc("DAY").lowercased()
            } else {
                moon.age = smc.moonAge.int.string + " " + loc("DAYS").lowercased()
            }
        } catch {
            debugPrint("Failure in SunMoonCalculator (moon)")
        }

        DispatchQueue.main.async {
            self.delegate?.moonDataReady(moon: self.moon)
        }
    }

    /// Returns the last fetched moon data.
    open func getOldMoonData() -> MoonInfoModel {
        return moon
    }

    // MARK: - Support functions

    private func moonTilt(date: NSDate, location: CLLocationCoordinate2D) -> (tanAlfa: Double, tanBeta: Double, diff: Double) {
        let moonAltitude = BDAstroCalc.moonPosition(date: date, location: location).altitude
        let moonAzimuth = BDAstroCalc.moonPosition(date: date, location: location).azimuth
        let moonPhase = BDAstroCalc.moonPhase(date: date).phase
        let sunAltitude = BDAstroCalc.sunPosition(date: date, location: location).altitude
        let sunAzimuth = BDAstroCalc.sunPosition(date: date, location: location).azimuth

        let absAzimMoonSun = abs(sunAzimuth - moonAzimuth)
        let tanAlfa = ((cos(moonAltitude) * tan(sunAltitude)) - (sin(moonAltitude) * cos(absAzimMoonSun))) / sin(absAzimMoonSun)
        let tanBeta = (sin(moonAltitude) - sin(sunAltitude)) / (cos(sunAltitude) * sin(absAzimMoonSun))

        var diff = 0.0
        if moonPhase <= 0.5 {
            diff = (absAzimMoonSun.radiansToDegrees) <= 180 ? atan(-tanAlfa) : atan(tanAlfa)
        } else {
            diff = (absAzimMoonSun.radiansToDegrees) <= 180 ? atan(tanAlfa) : atan(-tanAlfa)
        }

        return (tanAlfa, -tanBeta, diff)
    }

    private func getMoonPhaseIcon(_ phase: Double) -> UIImage {
        if phase >= 0 && phase <= 0.03448275862 { return UIImage(named: "wi-moon-alt-new", in: .module, with: nil)! }
        if phase > 0.03448275862 && phase <= 0.06896551724 { return UIImage(named: "wi-moon-alt-waxing-crescent-1", in: .module, with: nil)! }
        if phase > 0.06896551724 && phase <= 0.10344827586 { return UIImage(named: "wi-moon-alt-waxing-crescent-2", in: .module, with: nil)! }
        if phase > 0.10344827586 && phase <= 0.13793103448 { return UIImage(named: "wi-moon-alt-waxing-crescent-3", in: .module, with: nil)! }
        if phase > 0.13793103448 && phase <= 0.1724137931 { return UIImage(named: "wi-moon-alt-waxing-crescent-4", in: .module, with: nil)! }
        if phase > 0.1724137931 && phase <= 0.20689655172 { return UIImage(named: "wi-moon-alt-waxing-crescent-5", in: .module, with: nil)! }
        if phase > 0.20689655172 && phase <= 0.24137931034 { return UIImage(named: "wi-moon-alt-waxing-crescent-6", in: .module, with: nil)! }
        if phase > 0.24137931034 && phase <= 0.27586206896 { return UIImage(named: "wi-moon-alt-first-quarter", in: .module, with: nil)! }
        if phase > 0.27586206896 && phase <= 0.31034482758 { return UIImage(named: "wi-moon-alt-waxing-gibbous-1", in: .module, with: nil)! }
        if phase > 0.31034482758 && phase <= 0.3448275862 { return UIImage(named: "wi-moon-alt-waxing-gibbous-2", in: .module, with: nil)! }
        if phase > 0.3448275862 && phase <= 0.37931034482 { return UIImage(named: "wi-moon-alt-waxing-gibbous-3", in: .module, with: nil)! }
        if phase > 0.37931034482 && phase <= 0.41379310344 { return UIImage(named: "wi-moon-alt-waxing-gibbous-4", in: .module, with: nil)! }
        if phase > 0.41379310344 && phase <= 0.44827586206 { return UIImage(named: "wi-moon-alt-waxing-gibbous-5", in: .module, with: nil)! }
        if phase > 0.44827586206 && phase <= 0.48275862068 { return UIImage(named: "wi-moon-alt-waxing-gibbous-6", in: .module, with: nil)! }
        if phase > 0.48275862068 && phase <= 0.5172413793 { return UIImage(named: "wi-moon-alt-full", in: .module, with: nil)! }
        if phase > 0.5172413793 && phase <= 0.55172413792 { return UIImage(named: "wi-moon-alt-waning-gibbous-1", in: .module, with: nil)! }
        if phase > 0.55172413792 && phase <= 0.58620689654 { return UIImage(named: "wi-moon-alt-waning-gibbous-2", in: .module, with: nil)! }
        if phase > 0.58620689654 && phase <= 0.62068965516 { return UIImage(named: "wi-moon-alt-waning-gibbous-3", in: .module, with: nil)! }
        if phase > 0.62068965516 && phase <= 0.65517241378 { return UIImage(named: "wi-moon-alt-waning-gibbous-4", in: .module, with: nil)! }
        if phase > 0.65517241378 && phase <= 0.6896551724 { return UIImage(named: "wi-moon-alt-waning-gibbous-5", in: .module, with: nil)! }
        if phase > 0.6896551724 && phase <= 0.72413793102 { return UIImage(named: "wi-moon-alt-waning-gibbous-6", in: .module, with: nil)! }
        if phase > 0.72413793102 && phase <= 0.75862068964 { return UIImage(named: "wi-moon-alt-third-quarter", in: .module, with: nil)! }
        if phase > 0.75862068964 && phase <= 0.79310344826 { return UIImage(named: "wi-moon-alt-waning-crescent-1", in: .module, with: nil)! }
        if phase > 0.79310344826 && phase <= 0.82758620688 { return UIImage(named: "wi-moon-alt-waning-crescent-2", in: .module, with: nil)! }
        if phase > 0.82758620688 && phase <= 0.8620689655 { return UIImage(named: "wi-moon-alt-waning-crescent-3", in: .module, with: nil)! }
        if phase > 0.8620689655 && phase <= 0.89655172412 { return UIImage(named: "wi-moon-alt-waning-crescent-4", in: .module, with: nil)! }
        if phase > 0.89655172412 && phase <= 0.93103448274 { return UIImage(named: "wi-moon-alt-waning-crescent-5", in: .module, with: nil)! }
        if phase > 0.93103448274 && phase <= 0.96551724136 { return UIImage(named: "wi-moon-alt-waning-crescent-6", in: .module, with: nil)! }
        if phase > 0.96551724136 && phase <= 1 { return UIImage(named: "wi-moon-alt-new", in: .module, with: nil)! }
        return UIImage(named: "moon", in: .module, with: nil)!
    }

    private func getMoonZodiacSignString(_ moonZodiacSign: EKMoonZodiacSign) -> String {
        switch moonZodiacSign {
        case .aries: return loc("ARIES")
        case .cancer: return loc("CANCER")
        case .taurus: return loc("TAURUS")
        case .leo: return loc("LEO")
        case .gemini: return loc("GEMINI")
        case .virgo: return loc("VIRGO")
        case .libra: return loc("LIBRA")
        case .capricorn: return loc("CAPRICORN")
        case .scorpio: return loc("SCORPIO")
        case .aquarius: return loc("AQUARIUS")
        case .sagittarius: return loc("SAGITTARIUS")
        case .pisces: return loc("PESCES")
        }
    }

    private func getMoonTrajectoryString(_ moonTrajectory: EKMoonTrajectory) -> String {
        switch moonTrajectory {
        case .ascendent: return loc("ASCENDENT")
        case .descendent: return loc("DESCENDENT")
        }
    }
}
