//
//  Preferences.swift
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

import Foundation

public enum SpeedUnit: String {
    case metersPerSecond = "meterSecondSpeed"
    case kilometersPerHour = "kilometerHoursSpeed"
    case knots = "knotSpeed"
    case milesPerHour = "milesHoursSpeed"
}

public struct MRGpsPreferences {
    public var speedUnit: SpeedUnit
    public var showMinutesInTimes: Bool
    public var autoRefreshSunMoon: Bool
    public var sunMoonRefreshInterval: TimeInterval
    public var useTrueNorth: Bool

    public init(
        speedUnit: SpeedUnit = .kilometersPerHour,
        showMinutesInTimes: Bool = true,
        autoRefreshSunMoon: Bool = false,
        sunMoonRefreshInterval: TimeInterval = 60,
        useTrueNorth: Bool = true
    ) {
        self.speedUnit = speedUnit
        self.showMinutesInTimes = showMinutesInTimes
        self.autoRefreshSunMoon = autoRefreshSunMoon
        self.sunMoonRefreshInterval = sunMoonRefreshInterval
        self.useTrueNorth = useTrueNorth
    }
}
