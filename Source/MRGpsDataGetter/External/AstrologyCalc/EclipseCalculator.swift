//
//  EclipseCalculator.swift
//  AstrologyCalc
//
//  Created by  Yuri on 02/04/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import UIKit
import Foundation
import SwifterSwift

public class EclipseCalculator {
    
    enum EclispeType: Int {
        case Solar = 0
        case Lunar = 1
    }
    
    
    /// Gets next or previous eclipse info nearest to the reference julian day
    /// - Parameters:
    ///   - date: jd julian day
    ///   - eclipseType: type of eclipse: Eclipse.SOLAR or Eclipse.LUNAR
    ///   - next: true to get next eclipse, false to get previous
    func getEclipseFor(date: Date, eclipseType: EclispeType, next: Bool) -> Eclipse {
        let e = Eclipse()
        
        let year = dayToYear(date)
        var k = Double(0), T = Double(0), TT = Double(0), TTT = Double(0),
        F = Double(0), S = Double(0), C = Double(0), M = Double(0),
        M_ = Double(0), P = Double(0), Tau = Double(0), n = Double(0)
        var eclipseFound = false
        
        // AFFC, p. 32, f. 32.2
        k = (year - 1900) * 12.3685
        k.round(.down)
        
        k = next ? k + Double(eclipseType.rawValue) * 0.5: k - Double(eclipseType.rawValue) * 0.5
        
        repeat {
            // AFFC, p. 128, f. 32.3
            T = k / 1236.85
            TT = T * T
            TTT = T * TT
            
            // Moon's argument of latitude
            // AFFC, p. 129
            F = 21.2964 + 390.67050646 * k - 0.0016528 * TT - 0.00000239 * TTT
            F = to360(F).degreesToRadians
            
            // AFFC, p. 132
            eclipseFound = fabs(sin(F)) < 0.36
            
            // no eclipse exactly, examine other lunation
            if !eclipseFound {
                if next {
                    k += 1
                } else {
                    k -= 1
                }
                continue
            }
            
            // BOTH ECLIPSE TYPES (SOLAR & LUNAR)
            
            // mean anomaly of the Sun
            // AFFC, p. 129
            M = 359.2242 + 29.10535608 * k - 0.0000333 * TT - 0.00000347 * TTT
            M = to360(M).degreesToRadians
            
            // mean anomaly of the Moon
            // AFFC, p. 129
            M_ = 306.0253 + 385.81691806 * k + 0.0107306 * TT + 0.00001236 * TTT
            M_ = to360(M_).degreesToRadians
            
            // time of mean phase
            // AFFC, p. 128, f. 32.1
            var timeByJulianDate: Double = 2415020.75933 + 29.53058868 * k + 0.0001178 * TT - 0.000000155 * TTT + 0.00033 * sin((166.56 + 132.87 * T - 0.009173 * TT).degreesToRadians)
            
            // time of maximum eclipse
            timeByJulianDate += (0.1734 - 0.000393 * T) * sin(M) + 0.0021 * sin(M + M) - 0.4068 * sin(M_) + 0.0161 * sin(M_ + M_) - 0.0051 * sin(M + M_) - 0.0074 * sin(M - M_) - 0.0104 * sin(F + F)
            
            var timeFormat = "HH:mm:ss"
            if Bool(Preferences.shared.getPreference("minutesTimes"))! == true {
                timeFormat = "HH:mm"
            }
            e.maxPhaseDate = gregorianDateFrom(julianTime: timeByJulianDate).string(withFormat: "dd/MM/yyyy - " + timeFormat)
            
            // AFFC, p. 133
            S = 5.19595 - 0.0048 * cos(M) + 0.0020 * cos(M + M) - 0.3283 * cos(M_) - 0.0060 * cos(M + M_) + 0.0041 * cos(M - M_)
            C = 0.2070 * sin(M) + 0.0024 * sin(M + M) - 0.0390 * sin(M_) + 0.0115 * sin(M_ + M_) - 0.0073 * sin(M + M_)  - 0.0067 * sin(M - M_) + 0.0117 * sin(F + F)
            let gamma = S * sin(F) + C * cos(F)
            e.gamma = gamma.string
            let u = 0.0059 + 0.0046 * cos(M) - 0.0182 * cos(M_) + 0.0004 * cos(M_ + M_) - 0.0005 * cos(M + M_)
            e.u = u.string
            var phase: Double = 1

            
            // SOLAR ECLIPSE
            if eclipseType == .Solar {
                // eclipse is not observable from the Earth
                if fabs(gamma) > 1.5432 + u {
                    eclipseFound = false
                    
                    k = k + (next ? 1: -1)
                    continue
                }
                
                // AFFC, p. 134
                // non-central eclipse
                if fabs(gamma) > 0.9972 && fabs(gamma) < 0.9972 + fabs(u) {
                    e.type = .SolarNoncenral
                    e.phase = (phase).string
                } else {
                    // central eclipse

                    e.phase = (phase).string
                    if u < 0 {
                        e.type = .SolarCentralTotal
                    }
                    if u > 0.0047 {
                        e.type = .SolarCentralAnnular
                    }
                    if u > 0 && u < 0.0047{
                        C = 0.00464 * (1 - gamma * gamma).squareRoot()
                        if (u < C) {
                            e.type = .SolarCentralAnnularTotal
                        } else {
                            e.type = .SolarCentralAnnular
                        }
                    }
                }
                
                // partial eclipse
                if fabs(gamma) > 0.9972 && fabs(gamma) < 1.5432 + u {
                    e.type = .SolarPartial
                    phase = (1.5432 + u - fabs(gamma)) / (0.5461 + u + u)
                    e.phase = ((1.5432 + u - fabs(gamma)) / (0.5461 + u + u)).string
                }
            } else {
                // LUNAR ECLIPSE
                
                
                e.rho = String(format: "%3.1f", 1.2847 + u) + loc("DEGREE")
                e.sigma = String(format: "%3.1f", 0.7494 - u) + loc("DEGREE")
                
                // Phase for umbral eclipse
                // AFFC, p. 135, f. 33.4
                e.phase = ((1.0129 - u - fabs(gamma)) / 0.5450).string
                
                if phase >= 1 {
                    e.type = .LunarUmbralTotal
                }
                
                if phase > 0 && phase < 1 {
                    e.type = .LunarUmbralPartial
                }
                
                // Check if elipse is penumral only
                if phase < 0 {
                    // AFC, p. 135, f. 33.3
                    e.type = .LunarPenumbral
                    e.phase = ((1.5572 + u - fabs(gamma)) / 0.5450).string
                }
                
                // no eclipse, if both phases is less than 0,
                // then examine other lunation
                if phase < 0 {
                    eclipseFound = false
                    
                    k = k + (next ? 1: -1)
                    continue
                }
                
                // eclipse was found, calculate remaining details
                // AFFC, p. 135
                P = 1.0129 - u
                Tau = 0.4679 - u
                n = 0.5458 + 0.0400 * cos(M_)
                
                // semiduration in penumbra
                C = u + 1.5573
                e.sdPenumbra = (60.0 / n * (C * C - gamma * gamma).squareRoot()).string
                
                // semiduration of partial phase
                e.sdPartial = (60.0 / n * (P * P - gamma * gamma).squareRoot()).string
                
                // semiduration of total phase
                e.sdTotal = (60.0 / n * (Tau * Tau - gamma * gamma).squareRoot()).string
            }
        } while (!eclipseFound)
        
        return e
    }
    
    
    //MARK: - Support functions for eclipse calculator
    
    private func isLeap(year: Int) -> Bool {
        if year < 1582 && year % 4 == 0 {
            return true
        }
        
        if year % 100 == 0 && (year / 100) % 4 != 0 {
            return false
        }
        
        if year % 4 == 0 {
            return true
        }
        
        return false
    }
    
    /// get day number in year
    private func dayOfYear(year: Int, month: Int, day: Int) -> Int {
        let K = isLeap(year: year) ? 1 : 2
        return ((275 * month) / 9) - K * ((month + 9) / 12) + day - 30
    }
    
    /// Converts date to year with fractions
    private func dayToYear(_ date: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        
        guard let year = components.year, let month = components.month, let day = components.day else {
            fatalError("Can't unwrap date components")
        }
        
        let dayOfCurrentYear = dayOfYear(year: year, month: month, day: day)
        
        return Double(year) + Double(dayOfCurrentYear) / 365.2425
    }
    
    // returns julian date timestamp from date by gregorian calendar
    private func jdFromDate(date: Date) -> Double {
        let JD_JAN_1_1970_0000GMT = 2440587.5
        return JD_JAN_1_1970_0000GMT + date.timeIntervalSince1970 / 86400
    }
    
    // returns gregorian date from julian calendar date timestamp
    private func gregorianDateFrom(julianTime: Double) -> Date {
        let JD_JAN_1_1970_0000GMT = 2440587.5
        return Date(timeIntervalSince1970: (julianTime - JD_JAN_1_1970_0000GMT) * 86400)
    }
    
    private func to360(_ angle: Double) -> Double {
        return angle.truncatingRemainder(dividingBy: 360.0) + (angle < 0 ? 360 : 0)
    }
    
}
