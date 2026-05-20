//
//  SunInfoModel.swift
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

public class SunInfoModel: NSObject {
    public final var timestamp: Date?

    public final var sunIcon: UIImage = .init(named: "sun", in: .module, with: nil)!

    public final var solarNoon: String?
    public final var nadir: String?

    public final var altitude: String?
    public final var azimuth: String?

    public final var astronomicalDuskSunrise: String?
    public final var nauticalDuskSunrise: String?
    public final var civilDuskSunrise: String?
    public final var sunriseStart: String?
    public final var sunriseEnd: String?
    public final var astronomicalDuskSunset: String?
    public final var nauticalDuskSunset: String?
    public final var civilDuskSunset: String?
    public final var sunsetStart: String?
    public final var sunsetEnd: String?

    public final var goldenHourSunriseStart: String?
    public final var goldenHourSunriseEnd: String?
    public final var goldenHourSunsetStart: String?
    public final var goldenHourSunsetEnd: String?
    public final var blueHourSunriseStart: String?
    public final var blueHourSunriseEnd: String?
    public final var blueHourSunsetStart: String?
    public final var blueHourSunsetEnd: String?

    public final var declination: String?
    public final var rightAscension: String?
    public final var zodiacSign: String?
    public final var phaseTitle: String?
    public final var horizontalPosition: String?

    public final var distance: String?

    public final var daylightHours: String?
}
