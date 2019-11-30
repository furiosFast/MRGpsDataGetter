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
import Alamofire

//MARK: - Shared variables

public var AFManager = Session()
public let meterSecondToKilometerHour = 3.6
public let meterSecondToKnot = 1.9438444924406
public let meterSecondToMilesHour = 2.236936
public let kilometerHourToKnot = 0.539957
public let milesHourToKnot = 0.868976
public let milesHourToMeterSecond = 0.44704
public let milesHourToKilometerHour = 1.60934
public let hpaToAtm = 0.00098692326672
public let hpaToBar = 0.001
//public let radiansToDegrees = 180 / Double.pi
public let bundleId = "org.fastdevsproject.altervista.MRGpsDataGetter"
public let appVersionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
public let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as! String
public let appBuildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
public let hexAppBuildNumber = String(appBuildNumber.int!, radix: 16, uppercase: true)


//MARK: - Shared functions

///Short function for localize string
func loc(_ localizedKey: String) -> String {
    return NSLocalizedString(localizedKey, comment: "")
}


/// Function that set the Alamofire configuration
/// - Parameter timeOut: time interval that indicate the time out for every call to the web service made with alamofire
func setAlamofire(_ timeOut: TimeInterval = 15.0){
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = timeOut
    configuration.timeoutIntervalForResource = timeOut
    configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    AFManager = Alamofire.Session(configuration: configuration)
}

/// Function that format the declination coord from a double value
/// - Parameter declination: declination angle (in degrees)
func declinationToString(_ declination: Double) -> String {
    var decSeconds = (declination * 3600).int
    let decDegrees = decSeconds / 3600
    decSeconds = abs(decSeconds % 3600)
    let decMinutes = decSeconds / 60
    decSeconds %= 60
    return String(format: "%d° %d' %d\"", abs(decDegrees), decMinutes, decSeconds)
}

//func rightAscensionToString(_ rightAscension: Double) -> String {
//    var decSeconds = (rightAscension * 3600).int
//    let decDegrees = decSeconds / 3600
//    decSeconds = abs(decSeconds % 3600)
//    let decMinutes = decSeconds / 60
//    decSeconds %= 60
//    return String(format: "%dh %dm %ds", abs(decDegrees), decMinutes, decSeconds)
//}

/// Function that return the wind name based on the device heading (compass)
/// - Parameter angle: wind angle (in degrees)
func getWindName(_ angle: Double) -> String {
    var windNameWithCardinalSign : String = ""
    switch angle {
        case 23..<67: windNameWithCardinalSign = loc("positionWind_NE")
        case 67..<114: windNameWithCardinalSign = loc("positionWind_E")
        case 114..<157: windNameWithCardinalSign = loc("positionWind_SE")
        case 157..<203: windNameWithCardinalSign = loc("positionWind_S")
        case 203..<246: windNameWithCardinalSign = loc("positionWind_SW")
        case 246..<294: windNameWithCardinalSign = loc("positionWind_W")
        case 294..<339: windNameWithCardinalSign = loc("positionWind_NW")
        case 339..<361, 0..<23: windNameWithCardinalSign = loc("positionWind_N")
        default: break
    }
    return windNameWithCardinalSign
}

/// Function that return the coordinate name (es.: N, E, S, ecc.) from the heading angle
/// - Parameter heading: the coordinate angle (in degrees)
func getAngleName(_ angle: Double) -> String {
    var name : String = ""
    switch angle {
        case 11.25..<33.75: name = loc("position_NNE")
        case 33.75..<56.25: name = loc("position_NE")
        case 56.25..<78.75: name = loc("position_ENE")
        case 78.75..<101.25: name = loc("position_E")
        case 101.25..<123.75: name = loc("position_ESE")
        case 123.75..<146.25: name = loc("position_SE")
        case 146.25..<168.75: name = loc("position_SSE")
        case 168.75..<191.25: name = loc("position_S")
        case 191.25..<213.75: name = loc("position_SSW")
        case 213.75..<236.25: name = loc("position_SW")
        case 236.25..<258.75: name = loc("position_WSW")
        case 258.75..<281.25: name = loc("position_W")
        case 281.25..<303.75: name = loc("position_WNW")
        case 303.75..<326.25: name = loc("position_NW")
        case 326.25..<348.75: name = loc("position_NNW")
        case 348.75..<361, 0..<11.25: name = loc("position_N")
        default: break
    }
    return name
}

/// Function that return the Beaufort force degree bassed on the wind speed in knot
/// - Parameter windSpeedKnot: wind speed (in knot)
func getBeaufortForce(_ windSpeedKnot: Double) -> String {
    var windSpeed = "0"
    switch windSpeedKnot {
        case 0..<1: windSpeed = "0"
        case 1..<4: windSpeed = "1"
        case 4..<7: windSpeed = "2"
        case 7..<11: windSpeed = "3"
        case 11..<17: windSpeed = "4"
        case 17..<22: windSpeed = "5"
        case 22..<28: windSpeed = "6"
        case 28..<34: windSpeed = "7"
        case 34..<41: windSpeed = "8"
        case 41..<48: windSpeed = "9"
        case 48..<56: windSpeed = "10"
        case 56..<65: windSpeed = "11"
        case 65..<71: windSpeed = "12"
        default: break
    }
    return windSpeed
}

/// Function that return a color for every Beaufort Scale Force
/// - Parameter windSpeedKnot: wind speed (in knot)
func getBeaufortForceColor(_ windSpeedKnot: Double) -> String {
    var hexColor : String = "#FFFFFF"
    switch windSpeedKnot {
        case 0..<1: hexColor = "#FFFFFF"
        case 1..<4: hexColor = "#CCFFFF"
        case 4..<7: hexColor = "#99FFCC"
        case 7..<11: hexColor = "#99FF99"
        case 11..<17: hexColor = "#99FF66"
        case 17..<22: hexColor = "#99FF00"
        case 22..<28: hexColor = "#CCFF00"
        case 28..<34: hexColor = "#FFFF00"
        case 34..<41: hexColor = "#FFCC00"
        case 41..<48: hexColor = "#FF9900"
        case 48..<56: hexColor = "#FF6600"
        case 56..<65: hexColor = "#FF3300"
        case 65..<71: hexColor = "#FF0000"
        default: break
    }
    return hexColor
}

/// Function that return the zodiac sign of sun/moon based on the right ascension
/// - Parameter rightAscension: the right asnension of Sun/Moon (in radians).
func getZodiacSign(_ rightAscension: Double) -> String {
    var rightAscension = (rightAscension + 360).int % 360
    if(rightAscension < 0) {
        rightAscension = -1 * rightAscension
    }
    var zodiacSign = loc("NOTAVAILABLENUMBER")
    switch rightAscension {
        case 0..<30: zodiacSign = loc("position_PESCITITLE")
        case 30..<60: zodiacSign = loc("position_ARIETETITLE")
        case 60..<90: zodiacSign = loc("position_TOROTITLE")
        case 90..<120: zodiacSign = loc("position_GEMELLITITLE")
        case 120..<150: zodiacSign = loc("position_CANCROTITLE")
        case 150..<180: zodiacSign = loc("position_LEONETITLE")
        case 180..<210: zodiacSign = loc("position_VERGINETITLE")
        case 210...240: zodiacSign = loc("position_BILANCIATITLE")
        case 240...270: zodiacSign = loc("position_SCORPIOTITLE")
        case 270...300: zodiacSign = loc("position_SAGITTARIOTITLE")
        case 300...330: zodiacSign = loc("position_CAPRICTITLE")
        case 330...360: zodiacSign = loc("position_ACQUARIOTITLE")
        default: break
    }
    return zodiacSign
}

//MARK: - Extensions

// Formatter
extension Formatter {
    
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        return formatter
    }()
    
}

// Int
extension Int {
    
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }

}

// String
public extension String {
    
    func toDate(format: String) -> Date? {
        return DateFormatter(format: format).date(from: self)
    }

}

// TimeInterval
extension TimeInterval {

    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
    }
    
}


// Date
let componentFlags : Set<Calendar.Component> = [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.weekdayOrdinal, Calendar.Component.hour,Calendar.Component.minute, Calendar.Component.second, Calendar.Component.weekday, Calendar.Component.weekdayOrdinal]

extension DateComponents {
    mutating func to12am() {
        self.hour = 0
        self.minute = 0
        self.second = 0
    }
    
    mutating func to12pm() {
        self.hour = 23
        self.minute = 59
        self.second = 59
    }
}

extension DateFormatter {
    convenience init (format: String) {
        self.init()
        dateFormat = format
        locale = Locale.current
    }
}

public extension Date {
    
    func toString (format:String) -> String? {
        return DateFormatter(format: format).string(from: self)
    }
    
    //Crea una data direttamente dai valori passati
    static func customDate(year ye:Int, month mo:Int, day da:Int, hour ho:Int, minute mi:Int, second se:Int) -> Date {
        var comps = DateComponents()
        comps.year = ye
        comps.month = mo
        comps.day = da
        comps.hour = ho
        comps.minute = mi
        comps.second = se
        let date = NSCalendar.current.date(from: comps)
        return date!
    }
    
    func localeString() -> String {
        let df = DateFormatter()
        df.locale = NSLocale.current
        df.timeStyle = .medium
        df.dateStyle = .short
        return df.string(from: self)
    }
    
    struct Gregorian {
        static let calendar = Calendar(identifier: .gregorian)
    }
    var startOfWeek: Date? {
        return Gregorian.calendar.date(from: Gregorian.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
    
    func startOfWeek(weekday: Int?) -> Date {
        var cal = Calendar.current
        var component = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        component.to12am()
        cal.firstWeekday = weekday ?? 1
        return cal.date(from: component)!
    }
    
    func endOfWeek(weekday: Int) -> Date {
        let cal = Calendar.current
        var component = DateComponents()
        component.weekOfYear = 1
        component.day = -1
        component.to12pm()
        return cal.date(byAdding: component, to: startOfWeek(weekday: weekday))!
    }
    
    static func customDateUInt(year ye:UInt, month mo:UInt, day da:UInt, hour ho:UInt, minute mi:UInt, second se:UInt) -> Date {
        var comps = DateComponents()
        comps.year = Int(ye)
        comps.month = Int(mo)
        comps.day = Int(da)
        comps.hour = Int(ho)
        comps.minute = Int(mi)
        comps.second = Int(se)
        let date = NSCalendar.current.date(from: comps)
        return date!
    }
    
    static func dateOfMonthAgo() -> Date {
        return Date().addingTimeInterval(-24 * 30 * 60 * 60)
    }
    
    static func dateOfWeekAgo() -> Date {
        return Date().addingTimeInterval(-24 * 7 * 60 * 60)
    }
    
    func sameDate(ofDate:Date) -> Bool {
        let cal = NSCalendar.current
        let dif = cal.compare(self, to: ofDate, toGranularity: Calendar.Component.day)
        if dif == .orderedSame {
            return true
        } else {
            return false
        }
    }
    
    static func currentCalendar() -> Calendar {
        return Calendar.autoupdatingCurrent
    }
    
    func isEqualToDateIgnoringTime(_ aDate:Date) -> Bool {
        let components1 = Date.currentCalendar().dateComponents(componentFlags, from: self)
        let components2 = Date.currentCalendar().dateComponents(componentFlags, from: aDate)
        
        return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day))
    }
    
    func plusSeconds(_ s: Int) -> Date {
        return self.addComponentsToDate(seconds: s, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    func minusSeconds(_ s: UInt) -> Date {
        return self.addComponentsToDate(seconds: -Int(s), minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    func plusMinutes(_ m: Int) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: m, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    func minusMinutes(_ m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: -Int(m), hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    func plusHours(_ h: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: Int(h), days: 0, weeks: 0, months: 0, years: 0)
    }
    
    func minusHours(_ h: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: -Int(h), days: 0, weeks: 0, months: 0, years: 0)
    }
    
    func plusDays(_ d: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: Int(d), weeks: 0, months: 0, years: 0)
    }
    
    func minusDays(_ d: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: -Int(d), weeks: 0, months: 0, years: 0)
    }
    
    func plusWeeks(_ w: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: Int(w), months: 0, years: 0)
    }
    
    func minusWeeks(_ w: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: -Int(w), months: 0, years: 0)
    }
    
    func plusMonths(_ m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: Int(m), years: 0)
    }
    
    func minusMonths(_ m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: -Int(m), years: 0)
    }
    
    func plusYears(_ y: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: Int(y))
    }
    
    func minusYears(_ y: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: -Int(y))
    }
    
    private func addComponentsToDate(seconds sec: Int, minutes min: Int, hours hrs: Int, days d: Int, weeks wks: Int, months mts: Int, years yrs: Int) -> Date {
        var dc:DateComponents = DateComponents()
        dc.second = sec
        dc.minute = min
        dc.hour = hrs
        dc.day = d
        dc.weekOfYear = wks
        dc.month = mts
        dc.year = yrs
        return Calendar.current.date(byAdding: dc, to: self, wrappingComponents: false)!
    }
    
    func midnightUTCDate() -> Date {
        var dc:DateComponents = Calendar.current.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day], from: self)
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        dc.nanosecond = 0
        (dc as NSDateComponents).timeZone = TimeZone(secondsFromGMT: 0)
        
        return Calendar.current.date(from: dc)!
    }
    
    func secondsBetween(date1 d1:Date, date2 d2:Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.second!
    }

    func minutesBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.minute!
    }

    func hoursBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.hour!
    }

    func daysBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.day!
    }

    func weeksBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.weekOfYear!
    }

    func monthsBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.month!
    }

    func yearsBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.year!
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
    
    
    //Comparison Methods
    
    func isGreaterThan(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedDescending)
    }
    
    func isLessThan(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedAscending)
    }
    
    
    //Computed Properties
    
    var day: UInt {
        return UInt(Calendar.current.component(.day, from: self))
    }
    
    var month: UInt {
        return UInt(Calendar.current.component(.month, from: self))
    }
    
    var year: UInt {
        return UInt(Calendar.current.component(.year, from: self))
    }
    
    var hour: UInt {
        return UInt(Calendar.current.component(.hour, from: self))
    }
    
    var minute: UInt {
        return UInt(Calendar.current.component(.minute, from: self))
    }
    
    var second: UInt {
        return UInt(Calendar.current.component(.second, from: self))
    }
}

// Thread
extension Thread {

    var threadName: String {
        if let currentOperationQueue = OperationQueue.current?.name {
            return "OperationQueue: \(currentOperationQueue)"
        } else if let underlyingDispatchQueue = OperationQueue.current?.underlyingQueue?.label {
            return "DispatchQueue: \(underlyingDispatchQueue)"
        } else {
            let name = __dispatch_queue_get_label(nil)
            return String(cString: name, encoding: .utf8) ?? Thread.current.description
        }
    }

}
