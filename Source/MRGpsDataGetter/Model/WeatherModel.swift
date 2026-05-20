//
//  WeatherModel.swift
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

import CoreLocation
import UIKit

public class WeatherModel: NSObject {
    public final var timestamp: Date?
    public final var currentWeatherLocation: CLLocation?

    // Wind
    public final var windDegree: Double?
    public final var windName: String?
    public final var windSpeed: Double?
    public final var windSpeedGust: Double?
    public final var beaufortScaleWindSpeed: Int?
    public final var beaufortScaleWindColourForWindSpeed: String?
    public final var beaufortScaleWindSpeedGust: Int?
    public final var beaufortScaleWindColourForWindSpeedGust: String?

    // Condition
    public final var weatherDescription: String?
    public final var weatherSymbolName: String?
    public final var weatherCondition: String?

    // Precipitation
    public final var precipitationIntensity: Double?
    public final var precipitationChance: Double?
    public final var precipitationType: String?
    public final var snowfallIntensity: Double?

    // Atmosphere
    public final var visibility: Double?
    public final var humidity: Double?
    public final var pressure: Double?
    public final var pressureTrend: String?
    public final var clouds: Double?

    // UV & Dew
    public final var uvIndex: Int?
    public final var uvIndexCategory: String?
    public final var dewPoint: Double?
    public final var isDaylight: Bool?

    // Temperature
    public final var temp: Double?
    public final var feelsLike: Double?
    public final var tempMin: Double?
    public final var tempMax: Double?

    // Date/Time
    public final var date: Date?
    public final var time: String?
    public final var dateTime: String?
}
