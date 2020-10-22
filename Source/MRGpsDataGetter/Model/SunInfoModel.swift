//
//  SoleModel.swift
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
    
    public final var solarNoon : String = loc("NOTAVAILABLENUMBER")
    public final var nadir : String = loc("NOTAVAILABLENUMBER")
    
    public final var altitude : String = loc("NOTAVAILABLENUMBER")
    public final var azimuth : String = loc("NOTAVAILABLENUMBER")

    public final var astronomicalDuskSunrise : String = loc("NOTAVAILABLENUMBER")
    public final var nauticalDuskSunrise : String = loc("NOTAVAILABLENUMBER")
    public final var civilDuskSunrise : String = loc("NOTAVAILABLENUMBER")
    public final var sunriseStart : String = loc("NOTAVAILABLENUMBER")
    public final var sunriseEnd : String = loc("NOTAVAILABLENUMBER")
    public final var astronomicalDuskSunset : String = loc("NOTAVAILABLENUMBER")
    public final var nauticalDuskSunset : String = loc("NOTAVAILABLENUMBER")
    public final var civilDuskSunset : String = loc("NOTAVAILABLENUMBER")
    public final var sunsetStart : String = loc("NOTAVAILABLENUMBER")
    public final var sunsetEnd : String = loc("NOTAVAILABLENUMBER")
    
    public final var goldenHourSunriseStart : String = loc("NOTAVAILABLENUMBER")
    public final var goldenHourSunriseEnd : String = loc("NOTAVAILABLENUMBER")
    public final var goldenHourSunsetStart : String = loc("NOTAVAILABLENUMBER")
    public final var goldenHourSunsetEnd : String = loc("NOTAVAILABLENUMBER")
    public final var blueHourSunriseStart : String = loc("NOTAVAILABLENUMBER")
    public final var blueHourSunriseEnd : String = loc("NOTAVAILABLENUMBER")
    public final var blueHourSunsetStart : String = loc("NOTAVAILABLENUMBER")
    public final var blueHourSunsetEnd : String = loc("NOTAVAILABLENUMBER")

    public final var declination : String = loc("NOTAVAILABLENUMBER")
    public final var rightAscension : String = loc("NOTAVAILABLENUMBER")
    public final var zodiacSign : String = loc("NOTAVAILABLENUMBER")
    public final var phaseTitle : String = loc("NOTAVAILABLENUMBER")
    public final var horizontalPosition : String = loc("NOTAVAILABLENUMBER")

    public final var distance : String = loc("NOTAVAILABLENUMBER")
    
    public final var daylightHours : String = loc("NOTAVAILABLENUMBER")
}
