//
//  MeteoModel.swift
//  iWindRose²
//
//  Created by Marco on 25/03/18.
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
//

import UIKit
import CoreLocation

public final class GpsWeatherModel: NSObject {
    
    public final var windSpeed : String = loc("NOTAVAIABLENUMBER")
    public final var beaufortScale : String = loc("NOTAVAIABLENUMBER")
    public final var windDegree : String = loc("NOTAVAIABLENUMBER")
    public final var windName : String = loc("NOTAVAIABLENUMBER")
    public final var windIconName : String = loc("NOTAVAIABLENUMBER")
    public final var beaufortScaleWindColour : String = loc("NOTAVAIABLENUMBER")

    public final var weatherDescription : String = loc("NOTAVAIABLENUMBER")
    public final var weatherOpenWeatherMapIcon : String = loc("NOTAVAIABLENUMBER")
    
    public final var rain1h : String = loc("NOTAVAIABLENUMBER")
    public final var rain3h : String = loc("NOTAVAIABLENUMBER")
    public final var snow1h : String = loc("NOTAVAIABLENUMBER")
    public final var snow3h : String = loc("NOTAVAIABLENUMBER")
    public final var visibility : String = loc("NOTAVAIABLENUMBER")
    public final var umidity : String = loc("NOTAVAIABLENUMBER")
    public final var pressure : String = loc("NOTAVAIABLENUMBER")
    public final var pressureSeaLevel : String = loc("NOTAVAIABLENUMBER")
    public final var pressureGroundLevel : String = loc("NOTAVAIABLENUMBER")
    
    public final var clouds : String = loc("NOTAVAIABLENUMBER")

    public final var highTide : String = loc("NOTAVAIABLENUMBER")
    public final var lowMarea : String = loc("NOTAVAIABLENUMBER")

    public final var temp : String = loc("NOTAVAIABLENUMBER")
    public final var tempMin : String = loc("NOTAVAIABLENUMBER")
    public final var tempMax : String = loc("NOTAVAIABLENUMBER")
    
    public final var date : String = loc("NOTAVAIABLENUMBER")
    public final var time : String = loc("NOTAVAIABLENUMBER")
    public final var dateTime : String = loc("NOTAVAIABLENUMBER")

    public final var currentLocation: CLLocation? = nil
    public final var currentLocationName: String? = loc("NOTAVAIABLENUMBER")

}
