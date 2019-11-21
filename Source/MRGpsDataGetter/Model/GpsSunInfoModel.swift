//
//  SoleModel.swift
//  iWindRose²
//
//  Created by Marco on 17/04/18.
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
//

import UIKit

public final class GpsSunInfoModel: NSObject {
    
    public final var solarNoon : String = loc("NOTAVAIABLENUMBER")
    public final var nadir : String = loc("NOTAVAIABLENUMBER")
    
    public final var altitude : String = loc("NOTAVAIABLENUMBER")
    public final var azimuth : String = loc("NOTAVAIABLENUMBER")

    public final var astronomicalDuskSunrise : String = loc("NOTAVAIABLENUMBER")
    public final var nauticalDuskSunrise : String = loc("NOTAVAIABLENUMBER")
    public final var civilDuskSunrise : String = loc("NOTAVAIABLENUMBER")
    public final var sunriseStart : String = loc("NOTAVAIABLENUMBER")
    public final var sunriseEnd : String = loc("NOTAVAIABLENUMBER")
    public final var astronomicalDuskSunset : String = loc("NOTAVAIABLENUMBER")
    public final var nauticalDuskSunset : String = loc("NOTAVAIABLENUMBER")
    public final var civilDuskSunset : String = loc("NOTAVAIABLENUMBER")
    public final var sunsetStart : String = loc("NOTAVAIABLENUMBER")
    public final var sunsetEnd : String = loc("NOTAVAIABLENUMBER")
    
    public final var goldenHourSunriseStart : String = loc("NOTAVAIABLENUMBER")
    public final var goldenHourSunriseEnd : String = loc("NOTAVAIABLENUMBER")
    public final var goldenHourSunsetStart : String = loc("NOTAVAIABLENUMBER")
    public final var goldenHourSunsetEnd : String = loc("NOTAVAIABLENUMBER")
    public final var blueHourSunriseStart : String = loc("NOTAVAIABLENUMBER")
    public final var blueHourSunriseEnd : String = loc("NOTAVAIABLENUMBER")
    public final var blueHourSunsetStart : String = loc("NOTAVAIABLENUMBER")
    public final var blueHourSunsetEnd : String = loc("NOTAVAIABLENUMBER")

    public final var declination : String = loc("NOTAVAIABLENUMBER")
    public final var rightAscension : String = loc("NOTAVAIABLENUMBER")
    public final var zodiacSign : String = loc("NOTAVAIABLENUMBER")
    public final var phaseTitle : String = loc("NOTAVAIABLENUMBER")

    public final var daylightHours : String = loc("NOTAVAIABLENUMBER")

}
