//
//  ConfigShared.swift
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

// MARK: - Conversion constants

public let meterSecondToKilometerHour = 3.6
public let meterSecondToKnot = 1.9438444924406
public let meterSecondToMilesHour = 2.236936
public let kilometerHourToKnot = 0.539957
public let milesHourToKnot = 0.868976
public let milesHourToMeterSecond = 0.44704
public let milesHourToKilometerHour = 1.60934
public let hpaToAtm = 0.00098692326672
public let hpaToBar = 0.001

// MARK: - Localization

func loc(_ localizedKey: String) -> String {
    return NSLocalizedString(localizedKey, bundle: .module, comment: "")
}

public func locFromBundle(_ localizedKey: String) -> String {
    return loc(localizedKey)
}

public func imgFromBundle(named: String) -> UIImage? {
    return UIImage(named: named, in: .module, with: nil)
}

// MARK: - Astronomy helpers

func declinationToString(_ declination: Double) -> String {
    var decSeconds = Int(declination * 3600)
    let decDegrees = decSeconds / 3600
    decSeconds = abs(decSeconds % 3600)
    let decMinutes = decSeconds / 60
    decSeconds %= 60
    return String(format: "%d° %d' %d\"", abs(decDegrees), decMinutes, decSeconds)
}

func getSunMoonVisibility(_ altitude: Double, isSun: Bool) -> String {
    if altitude >= 0 {
        return isSun ? loc("POSITIONSUN_POSITIVE") : loc("POSITIONMOON_POSITIVE")
    }
    return isSun ? loc("POSITIONSUN_NEGATIVE") : loc("POSITIONMOON_NEGATIVE")
}

// MARK: - Wind & direction

func getWindName(_ angle: Double) -> String {
    switch angle {
    case 23 ..< 67: return loc("WIND_NE")
    case 67 ..< 114: return loc("WIND_E")
    case 114 ..< 157: return loc("WIND_SE")
    case 157 ..< 203: return loc("WIND_S")
    case 203 ..< 246: return loc("WIND_SW")
    case 246 ..< 294: return loc("WIND_W")
    case 294 ..< 339: return loc("WIND_NW")
    case 339 ..< 361, 0 ..< 23: return loc("WIND_N")
    default: return ""
    }
}

func getAngleName(_ angle: Double) -> String {
    switch angle {
    case 11.25 ..< 33.75: return loc("NNE")
    case 33.75 ..< 56.25: return loc("NE")
    case 56.25 ..< 78.75: return loc("ENE")
    case 78.75 ..< 101.25: return loc("E")
    case 101.25 ..< 123.75: return loc("ESE")
    case 123.75 ..< 146.25: return loc("SE")
    case 146.25 ..< 168.75: return loc("SSE")
    case 168.75 ..< 191.25: return loc("S")
    case 191.25 ..< 213.75: return loc("SSW")
    case 213.75 ..< 236.25: return loc("SW")
    case 236.25 ..< 258.75: return loc("WSW")
    case 258.75 ..< 281.25: return loc("W")
    case 281.25 ..< 303.75: return loc("WNW")
    case 303.75 ..< 326.25: return loc("NW")
    case 326.25 ..< 348.75: return loc("NNW")
    case 348.75 ..< 361, 0 ..< 11.25: return loc("N")
    default: return ""
    }
}

// MARK: - Beaufort scale

func getBeaufortForce(_ windSpeedKnot: Double) -> String {
    switch windSpeedKnot {
    case 0 ..< 1: return "0"
    case 1 ..< 4: return "1"
    case 4 ..< 7: return "2"
    case 7 ..< 11: return "3"
    case 11 ..< 17: return "4"
    case 17 ..< 22: return "5"
    case 22 ..< 28: return "6"
    case 28 ..< 34: return "7"
    case 34 ..< 41: return "8"
    case 41 ..< 48: return "9"
    case 48 ..< 56: return "10"
    case 56 ..< 65: return "11"
    case 65...: return "12"
    default: return "0"
    }
}

func getBeaufortForceColor(_ windSpeedKnot: Double) -> String {
    switch windSpeedKnot {
    case 0 ..< 1: return "#FFFFFF"
    case 1 ..< 4: return "#CCFFFF"
    case 4 ..< 7: return "#99FFCC"
    case 7 ..< 11: return "#99FF99"
    case 11 ..< 17: return "#99FF66"
    case 17 ..< 22: return "#99FF00"
    case 22 ..< 28: return "#CCFF00"
    case 28 ..< 34: return "#FFFF00"
    case 34 ..< 41: return "#FFCC00"
    case 41 ..< 48: return "#FF9900"
    case 48 ..< 56: return "#FF6600"
    case 56 ..< 65: return "#FF3300"
    case 65...: return "#FF0000"
    default: return "#FFFFFF"
    }
}

// MARK: - Date helpers

func getDateFrom(_ date: Date, utc: Bool = false) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    if utc {
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
    }
    let dc = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    return Calendar.current.date(from: dc) ?? date
}

// MARK: - Extensions

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Int {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension TimeInterval {
    func stringFromTimeInterval() -> String {
        let time = Int(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
    }
}
