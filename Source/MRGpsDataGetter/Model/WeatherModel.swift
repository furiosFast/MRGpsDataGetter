//
//  MeteoModel.swift
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
import CoreLocation

public class WeatherModel: NSObject {
    
    public final var windSpeed : String = loc("NOTAVAILABLENUMBER")
    public final var windDegree : String = loc("NOTAVAILABLENUMBER")
    public final var windName : String = loc("NOTAVAILABLENUMBER")
    public final var beaufortScale : String = loc("NOTAVAILABLENUMBER")
    public final var beaufortScaleWindColour : String = loc("NOTAVAILABLENUMBER")

    public final var weatherDescription : String = loc("NOTAVAILABLENUMBER")
    public final var weatherOpenWeatherMapIcon : String = loc("NOTAVAILABLENUMBER")
    
    public final var rain1h : String = loc("NOTAVAILABLENUMBER")
    public final var rain3h : String = loc("NOTAVAILABLENUMBER")
    public final var snow1h : String = loc("NOTAVAILABLENUMBER")
    public final var snow3h : String = loc("NOTAVAILABLENUMBER")
    public final var visibility : String = loc("NOTAVAILABLENUMBER")
    public final var umidity : String = loc("NOTAVAILABLENUMBER")
    public final var pressure : String = loc("NOTAVAILABLENUMBER")
    public final var pressureSeaLevel : String = loc("NOTAVAILABLENUMBER")
    public final var pressureGroundLevel : String = loc("NOTAVAILABLENUMBER")
    
    public final var clouds : String = loc("NOTAVAILABLENUMBER")

    public final var highTide : String = loc("NOTAVAILABLENUMBER")
    public final var lowMarea : String = loc("NOTAVAILABLENUMBER")

    public final var temp : String = loc("NOTAVAILABLENUMBER")
    public final var tempMin : String = loc("NOTAVAILABLENUMBER")
    public final var tempMax : String = loc("NOTAVAILABLENUMBER")
    
    public final var date : String = loc("NOTAVAILABLENUMBER")
    public final var time : String = loc("NOTAVAILABLENUMBER")
    public final var dateTime : String = loc("NOTAVAILABLENUMBER")

    public final var currentWeatherLocation: CLLocation? = nil
//    public final var currentLocationName: String? = loc("NOTAVAILABLENUMBER")

}
