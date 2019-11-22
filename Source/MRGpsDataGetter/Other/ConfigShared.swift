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

public let meterSecondToKilometerHour = 3.6
public let meterSecondToKnot = 1.9438444924406
public let meterSecondToMilesHour = 2.236936
public let kilometerHourToKnot = 0.539957
public let milesHourToKnot = 0.868976
public let milesHourToMeterSecond = 0.44704
public let milesHourToKilometerHour = 1.60934
public let hpaToAtm = 0.00098692326672
public let hpaToBar = 0.001
public let radiansToDegrees = 180 / Double.pi
public let bundleId = "org.fastdevsproject.altervista.MRGpsDataGetter"
public let appVersionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
public let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as! String
public let appBuildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
public let hexAppBuildNumber = String(Int(appBuildNumber)!, radix: 16, uppercase: true)


///Function that set the Alamofire configuration
public func AFManager() -> Session {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 15.0
    configuration.timeoutIntervalForResource = 15.0
    configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    return Alamofire.Session(configuration: configuration)
}

///Function that format the declination coord from a double value
func declinationToString(_ declination: Double) -> String {
    var decSeconds = Int(declination * 3600)
    let decDegrees = decSeconds / 3600
    decSeconds = abs(decSeconds % 3600)
    let decMinutes = decSeconds / 60
    decSeconds %= 60
    return String(format: "%d° %d' %d\"", abs(decDegrees), decMinutes, decSeconds)
}

//func rightAscensionToString(_ rightAscension: Double) -> String {
//    var decSeconds = Int(rightAscension * 3600)
//    let decDegrees = decSeconds / 3600
//    decSeconds = abs(decSeconds % 3600)
//    let decMinutes = decSeconds / 60
//    decSeconds %= 60
//    return String(format: "%dh %dm %ds", abs(decDegrees), decMinutes, decSeconds)
//}

///Function that return the wind name based on the device heading (compass)
func getWindName(_ heading: Double) -> String {
    var gradiNomeVento : String = ""
    switch heading {
        case 23..<67: gradiNomeVento = loc("positionWind_NE")
        case 67..<114: gradiNomeVento = loc("positionWind_E")
        case 114..<157: gradiNomeVento = loc("positionWind_SE")
        case 157..<203: gradiNomeVento = loc("positionWind_S")
        case 203..<246: gradiNomeVento = loc("positionWind_SW")
        case 246..<294: gradiNomeVento = loc("positionWind_W")
        case 294..<339: gradiNomeVento = loc("positionWind_NW")
        case 339..<361, 0..<23: gradiNomeVento = loc("positionWind_N")
        default: break
    }
    return gradiNomeVento
}

///Function that return the coordinate name (es.: N, E, S, ecc.) from the heading angle
func getAngleName(_ heading: Double) -> String {
    var angolo : String = ""
    switch heading {
        case 11.25..<33.75: angolo = loc("position_NNE")
        case 33.75..<56.25: angolo = loc("position_NE")
        case 56.25..<78.75: angolo = loc("position_ENE")
        case 78.75..<101.25: angolo = loc("position_E")
        case 101.25..<123.75: angolo = loc("position_ESE")
        case 123.75..<146.25: angolo = loc("position_SE")
        case 146.25..<168.75: angolo = loc("position_SSE")
        case 168.75..<191.25: angolo = loc("position_S")
        case 191.25..<213.75: angolo = loc("position_SSW")
        case 213.75..<236.25: angolo = loc("position_SW")
        case 236.25..<258.75: angolo = loc("position_WSW")
        case 258.75..<281.25: angolo = loc("position_W")
        case 281.25..<303.75: angolo = loc("position_WNW")
        case 303.75..<326.25: angolo = loc("position_NW")
        case 326.25..<348.75: angolo = loc("position_NNW")
        case 348.75..<361, 0..<11.25: angolo = loc("position_N")
        default: break
    }
    return angolo
}

///Function that return the Beaufort force degree bassed on the wind speed in knot
func getBeaufortForce(_ windSpeedKnot: Double) -> String {
    switch windSpeedKnot {
        case 0..<1: return "0"
        case 1..<4: return "1"
        case 4..<7: return "2"
        case 7..<11: return "3"
        case 11..<17: return "4"
        case 17..<22: return "5"
        case 22..<28: return "6"
        case 28..<34: return "7"
        case 34..<41: return "8"
        case 41..<48: return "9"
        case 48..<56: return "10"
        case 56..<65: return "11"
        case 65..<71: return "12"
        default: break
    }
    return "0"
}

///Function that return a color for every Beaufort Scale Force
func getBeaufortForceColor(_ windSpeedKnot: Double) -> String {
    var coloreBollinoForzaBeaufort : String = "#FFFFFF"
    switch windSpeedKnot {
        case 0..<1: coloreBollinoForzaBeaufort = "#FFFFFF"
        case 1..<4: coloreBollinoForzaBeaufort = "#CCFFFF"
        case 4..<7: coloreBollinoForzaBeaufort = "#99FFCC"
        case 7..<11: coloreBollinoForzaBeaufort = "#99FF99"
        case 11..<17: coloreBollinoForzaBeaufort = "#99FF66"
        case 17..<22: coloreBollinoForzaBeaufort = "#99FF00"
        case 22..<28: coloreBollinoForzaBeaufort = "#CCFF00"
        case 28..<34: coloreBollinoForzaBeaufort = "#FFFF00"
        case 34..<41: coloreBollinoForzaBeaufort = "#FFCC00"
        case 41..<48: coloreBollinoForzaBeaufort = "#FF9900"
        case 48..<56: coloreBollinoForzaBeaufort = "#FF6600"
        case 56..<65: coloreBollinoForzaBeaufort = "#FF3300"
        case 65..<71: coloreBollinoForzaBeaufort = "#FF0000"
        default: break
    }
    return coloreBollinoForzaBeaufort
}

/// Function that a format a string value of date
func UTCToLocal(_ date: Date, _ type: Int) -> String? {
    let dateFormatter = DateFormatter()
    switch type {
        case 0: dateFormatter.dateFormat = "dd/MM/yyyy"
        case 1: dateFormatter.dateFormat = "HH:mm:ss"
        case 2: dateFormatter.dateFormat = "dd/MM/yyyy - HH:mm:ss"
        case 3: dateFormatter.dateFormat = "HH:mm"
        case 4: dateFormatter.dateFormat = "EEEE, dd/MM/yyyy"
        default: return nil
    }
    dateFormatter.timeZone = NSTimeZone.local
    return dateFormatter.string(from: date)
}

///Function that return the zodiac sign of sun/moon based on the right ascension
func getZodiacSign(_ rightAscension: Double) -> String {
    var rightAscension = Int(rightAscension + 360) % 360
    if(rightAscension < 0) {
        rightAscension = -1 * rightAscension
    }
    switch rightAscension {
        case 0..<30: return loc("position_PESCITITLE")
        case 30..<60: return loc("position_ARIETETITLE")
        case 60..<90: return loc("position_TOROTITLE")
        case 90..<120: return loc("position_GEMELLITITLE")
        case 120..<150: return loc("position_CANCROTITLE")
        case 150..<180: return loc("position_LEONETITLE")
        case 180..<210: return loc("position_VERGINETITLE")
        case 210...240: return loc("position_BILANCIATITLE")
        case 240...270: return loc("position_SCORPIOTITLE")
        case 270...300: return loc("position_SAGITTARIOTITLE")
        case 300...330: return loc("position_CAPRICTITLE")
        case 330...360: return loc("position_ACQUARIOTITLE")
        default: return loc("NOTAVAIABLENUMBER")
    }
    
}
