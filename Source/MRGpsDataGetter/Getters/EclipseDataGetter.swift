//
//  EclipseCalculator.swift
//  AstrologyCalc
//
//  Created by  Yuri on 02/04/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import Foundation

public class EclipseDataGetter {
    
    public enum EclispeType: Int {
        case Solar = 0
        case Lunar = 1
    }
    
    /**
     * Gets next or previous eclipse info nearest to the reference julian day
     * @param jd julian day
     * @param eclipseType type of eclipse: Eclipse.SOLAR or Eclipse.LUNAR
     * @param next true to get next eclipse, false to get previous
     */
    public func getEclipseFor(date: Date, eclipseType: EclispeType, next: Bool) -> EclipseInfoModel {
        let e = EclipseInfoModel()
        
        let year = AstroUtils.dayToYear(date)
        var k = Double(0), T = Double(0), TT = Double(0), TTT = Double(0),
        F = Double(0), S = Double(0), C = Double(0), M = Double(0),
        M_ = Double(0), P = Double(0), Tau = Double(0), n = Double(0)
        var eclipseFound = false
        
        // AFFC, p. 32, f. 32.2
        k = (year - 1900) * 12.3685;
        k.round(.down)
        
        k = next ? k + Double(eclipseType.rawValue) * 0.5: k - Double(eclipseType.rawValue) * 0.5;
        
        repeat
        {
            // AFFC, p. 128, f. 32.3
            T = k / 1236.85;
            TT = T * T;
            TTT = T * TT;
            
            // Moon's argument of latitude
            // AFFC, p. 129
            F = 21.2964 + 390.67050646 * k
                - 0.0016528 * TT
                - 0.00000239 * TTT;
            
            F = AstroUtils.toRadians(AstroUtils.to360(F))
            
            // AFFC, p. 132
            eclipseFound = fabs(sin(F)) < 0.36
            
            // no eclipse exactly, examine other lunation
            if !eclipseFound {
                if next {
                  k += 1
                }
                else {
                  k -= 1
                }
                continue
            }
            
            // BOTH ECLIPSE TYPES (SOLAR & LUNAR)
            
            // mean anomaly of the Sun
            // AFFC, p. 129
            M = 359.2242 + 29.10535608 * k
            - 0.0000333 * TT
            - 0.00000347 * TTT;
            M = AstroUtils.toRadians(AstroUtils.to360(M))
            
            // mean anomaly of the Moon
            // AFFC, p. 129
            M_ = 306.0253 + 385.81691806 * k
            + 0.0107306 * TT
            + 0.00001236 * TTT;
            M_ = AstroUtils.toRadians(AstroUtils.to360(M_))
            
            // time of mean phase
            // AFFC, p. 128, f. 32.1
            var timeByJulianDate: Double = 2415020.75933 + 29.53058868 * k
            + 0.0001178 * TT
            - 0.000000155 * TTT
            + 0.00033 *
            sin(AstroUtils.toRadians(166.56 + 132.87 * T - 0.009173 * TT))
            
            // time of maximum eclipse
            timeByJulianDate += (0.1734 - 0.000393 * T) * sin(M)
            + 0.0021 * sin(M + M)
            - 0.4068 * sin(M_)
            + 0.0161 * sin(M_ + M_)
            - 0.0051 * sin(M + M_)
            - 0.0074 * sin(M - M_)
            - 0.0104 * sin(F + F);
            
            e.maxPhaseDate = AstroUtils.gregorianDateFrom(julianTime: timeByJulianDate)
            
            // AFFC, p. 133
            S = 5.19595
            - 0.0048 * cos(M)
            + 0.0020 * cos(M + M)
            - 0.3283 * cos(M_)
            - 0.0060 * cos(M + M_)
            + 0.0041 * cos(M - M_);
            
            C = 0.2070 * sin(M)
            + 0.0024 * sin(M + M)
            - 0.0390 * sin(M_)
            + 0.0115 * sin(M_ + M_)
            - 0.0073 * sin(M + M_)
            - 0.0067 * sin(M - M_)
            + 0.0117 * sin(F + F);
            
            e.gamma =
            S * sin(F) + C * cos(F);
            
            e.u =
            0.0059
            + 0.0046 * cos(M)
            - 0.0182 * cos(M_)
            + 0.0004 * cos(M_ + M_)
            - 0.0005 * cos(M + M_);
            
            // SOLAR ECLIPSE
            if eclipseType == .Solar {
                // eclipse is not observable from the Earth
                if fabs(e.gamma) > 1.5432 + e.u {
                    eclipseFound = false;
                    
                    k = k + (next ? 1: -1)
                    continue;
                }
                
                // AFFC, p. 134
                // non-central eclipse
                if fabs(e.gamma) > 0.9972 && fabs(e.gamma) < 0.9972 + fabs(e.u) {
                    e.type = .SolarNoncenral
                    e.phase = 1;
                }
                    // central eclipse
                else
                {
                    e.phase = 1;
                    if e.u < 0 {
                        e.type = .SolarCentralTotal
                    }
                    if e.u > 0.0047 {
                        e.type = .SolarCentralAnnular
                    }
                    if e.u > 0 && e.u < 0.0047{
                        C = 0.00464 * (1 - e.gamma * e.gamma).squareRoot()
                        if (e.u < C) {
                          e.type = .SolarCentralAnnularTotal
                        }
                        else {
                            e.type = .SolarCentralAnnular
                        }
                    }
                }
                
                // partial eclipse
                if fabs(e.gamma) > 0.9972 && fabs(e.gamma) < 1.5432 + e.u {
                    e.type = .SolarPartial
                    e.phase = (1.5432 + e.u - fabs(e.gamma)) / (0.5461 + e.u + e.u);
                }
            }
                // LUNAR ECLIPSE
            else
            {
                e.rho = 1.2847 + e.u;
                e.sigma = 0.7494 - e.u;
                
                // Phase for umbral eclipse
                // AFFC, p. 135, f. 33.4
                e.phase = (1.0129 - e.u - fabs(e.gamma)) / 0.5450;
                
                if e.phase >= 1 {
                    e.type = .LunarUmbralTotal
                }
                
                if e.phase > 0 && e.phase < 1 {
                    e.type = .LunarUmbralPartial
                }
                
                // Check if elipse is penumral only
                if e.phase < 0 {
                    // AFC, p. 135, f. 33.3
                    e.type = .LunarPenumbral
                    e.phase = (1.5572 + e.u - fabs(e.gamma)) / 0.5450;
                }
                
                // no eclipse, if both phases is less than 0,
                // then examine other lunation
                if e.phase < 0 {
                    eclipseFound = false;
                    
                    k = k + (next ? 1: -1)
                    continue;
                }
                
                // eclipse was found, calculate remaining details
                // AFFC, p. 135
                P = 1.0129 - e.u;
                Tau = 0.4679 - e.u;
                n = 0.5458 + 0.0400 * cos(M_);
                
                // semiduration in penumbra
                C = e.u + 1.5573;
                e.sdPenumbra = 60.0 / n * (C * C - e.gamma * e.gamma).squareRoot()
                
                // semiduration of partial phase
                e.sdPartial = 60.0 / n * (P * P - e.gamma * e.gamma).squareRoot()
                
                // semiduration of total phase
                e.sdTotal = 60.0 / n * (Tau * Tau - e.gamma * e.gamma).squareRoot()
            }
        } while (!eclipseFound);
        
        return e;
    }
    
}

class AstroUtils {

    public static func isLeap(year: Int) -> Bool {
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
    static func dayOfYear(year: Int, month: Int, day: Int) -> Int {
        let K = AstroUtils.isLeap(year: year) ? 1 : 2
        return ((275 * month) / 9) - K * ((month + 9) / 12) + day - 30
    }

    /// Converts date to year with fractions
    static func dayToYear(_ date: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date)

        guard let year = components.year, let month = components.month, let day = components.day else {
            fatalError("Can't unwrap date components")
        }

        let dayOfYear = AstroUtils.dayOfYear(
            year: year,
            month: month,
            day: day
        )

        return Double(year) + Double(dayOfYear) / 365.2425;
    }

    // returns julian date timestamp from date by gregorian calendar
    static func jdFromDate(date: Date) -> Double {
        let JD_JAN_1_1970_0000GMT = 2440587.5
        return JD_JAN_1_1970_0000GMT + date.timeIntervalSince1970 / 86400
    }

    // returns gregorian date from julian calendar date timestamp
    static func gregorianDateFrom(julianTime: Double) -> Date {
        let JD_JAN_1_1970_0000GMT = 2440587.5
        return Date(timeIntervalSince1970: (julianTime - JD_JAN_1_1970_0000GMT) * 86400)
    }

    static func to360(_ angle: Double) -> Double {
        return angle.truncatingRemainder(dividingBy: 360.0) + (angle < 0 ? 360 : 0)
    }

    // convert angle to radians
    static func toRadians(_ angle: Double) -> Double {
        return angle * .pi / 180
    }

}
