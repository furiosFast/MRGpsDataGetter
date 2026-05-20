//
//  ForecastDataGetter.swift
//  MRGpsDataGetter
//
//  Created by Marco Ricca on 20/11/2019
//  Copyright © 2019 Fast-Devs Project. All rights reserved.
//

import CoreLocation
import UIKit
import WeatherKit

@objc public protocol MRGpsDataGetterForecastDataDelegate: NSObjectProtocol {
    /// Called when hourly forecast data is ready.
    func forecastDataReady(forecast: [WeatherModel])
    /// Called when daily forecast data is ready.
    @objc optional func dailyForecastDataReady(forecast: [WeatherModel])
    /// Called when forecast data cannot be retrieved.
    @objc optional func forecastDataNotAvailable(error: String)
}

/// Fetches hourly and daily forecast via Apple WeatherKit.
/// All values are returned in SI units: temperature in °C, wind in m/s, pressure in hPa,
/// visibility in km, precipitation in mm, humidity and cloud cover as 0-1 fractions.
open class ForecastDataGetter: NSObject, @unchecked Sendable {
    open weak var delegate: MRGpsDataGetterForecastDataDelegate?

    private(set) var forecast: [WeatherModel] = []
    private(set) var dailyForecast: [WeatherModel] = []

    private let weatherService = WeatherService.shared

    /// Fetches hourly + daily forecast. Results delivered via delegate on the main thread.
    open func getForecastInfo(currentLocation: CLLocation) {
        Task {
            do {
                let weather = try await weatherService.weather(
                    for: currentLocation,
                    including: .hourly, .daily
                )

                let hourlyForecast = weather.0
                let dailyForecastData = weather.1

                self.forecast = []
                self.dailyForecast = []
                let timestamp = Date()

                for hourWeather in hourlyForecast {
                    let model = WeatherModel()
                    model.timestamp = timestamp
                    model.currentWeatherLocation = currentLocation
                    model.weatherCondition = hourWeather.condition.rawValue
                    model.weatherDescription = hourWeather.condition.description
                    model.weatherSymbolName = hourWeather.symbolName
                    model.isDaylight = hourWeather.isDaylight

                    // Wind speed (m/s), gust (m/s), direction (degrees)
                    let windSpeedMS = hourWeather.wind.speed.converted(to: .metersPerSecond).value
                    model.windSpeed = windSpeedMS
                    model.windSpeedGust = hourWeather.wind.gust?.converted(to: .metersPerSecond).value

                    let windAngle = hourWeather.wind.direction.converted(to: .degrees).value
                    model.windDegree = windAngle
                    model.windName = getWindName(windAngle)

                    // Beaufort scale (0-12 integer + hex color)
                    let windKnot = windSpeedMS * meterSecondToKnot
                    model.beaufortScaleWindSpeed = Int(getBeaufortForce(windKnot)) ?? 0
                    model.beaufortScaleWindColourForWindSpeed = getBeaufortForceColor(windKnot)

                    if let gustMS = model.windSpeedGust {
                        let gustKnot = gustMS * meterSecondToKnot
                        model.beaufortScaleWindSpeedGust = Int(getBeaufortForce(gustKnot)) ?? 0
                        model.beaufortScaleWindColourForWindSpeedGust = getBeaufortForceColor(gustKnot)
                    }

                    // Precipitation chance (0-1 fraction), amount (mm)
                    let precipChance = hourWeather.precipitationChance
                    model.precipitationChance = precipChance > 0 ? precipChance : nil

                    let precipAmount = hourWeather.precipitationAmount.converted(to: .millimeters).value
                    model.precipitationIntensity = precipAmount > 0 ? precipAmount : nil

                    // Visibility (km)
                    model.visibility = hourWeather.visibility.converted(to: .kilometers).value

                    // Pressure (hPa)
                    model.pressure = hourWeather.pressure.converted(to: .hectopascals).value

                    // Humidity (0-1 fraction)
                    model.humidity = hourWeather.humidity

                    // Temperature (°C)
                    model.temp = hourWeather.temperature.converted(to: .celsius).value
                    model.feelsLike = hourWeather.apparentTemperature.converted(to: .celsius).value
                    model.dewPoint = hourWeather.dewPoint.converted(to: .celsius).value

                    // UV Index (integer)
                    model.uvIndex = hourWeather.uvIndex.value
                    model.uvIndexCategory = hourWeather.uvIndex.category.description

                    // Cloud cover (0-1 fraction), nil if clear
                    let cloudCover = hourWeather.cloudCover
                    model.clouds = cloudCover > 0 ? cloudCover : nil

                    // Date
                    model.date = hourWeather.date
                    model.time = Self.timeFormatter.string(from: hourWeather.date)
                    model.dateTime = Self.dateTimeFormatter.string(from: hourWeather.date)

                    self.forecast.append(model)
                }

                for dayWeather in dailyForecastData {
                    let model = WeatherModel()
                    model.timestamp = timestamp
                    model.currentWeatherLocation = currentLocation
                    model.weatherCondition = dayWeather.condition.rawValue
                    model.weatherDescription = dayWeather.condition.description
                    model.weatherSymbolName = dayWeather.symbolName

                    // Wind speed (m/s), gust (m/s), direction (degrees)
                    let windSpeedMS = dayWeather.wind.speed.converted(to: .metersPerSecond).value
                    model.windSpeed = windSpeedMS
                    model.windSpeedGust = dayWeather.wind.gust?.converted(to: .metersPerSecond).value

                    let windAngle = dayWeather.wind.direction.converted(to: .degrees).value
                    model.windDegree = windAngle
                    model.windName = getWindName(windAngle)

                    // Beaufort scale (0-12 integer + hex color)
                    let windKnot = windSpeedMS * meterSecondToKnot
                    model.beaufortScaleWindSpeed = Int(getBeaufortForce(windKnot)) ?? 0
                    model.beaufortScaleWindColourForWindSpeed = getBeaufortForceColor(windKnot)

                    if let gustMS = model.windSpeedGust {
                        let gustKnot = gustMS * meterSecondToKnot
                        model.beaufortScaleWindSpeedGust = Int(getBeaufortForce(gustKnot)) ?? 0
                        model.beaufortScaleWindColourForWindSpeedGust = getBeaufortForceColor(gustKnot)
                    }

                    // Temperature min/max (°C)
                    model.tempMin = dayWeather.lowTemperature.converted(to: .celsius).value
                    model.tempMax = dayWeather.highTemperature.converted(to: .celsius).value

                    // Precipitation chance (0-1 fraction), total amount (mm)
                    let precipChance = dayWeather.precipitationChance
                    model.precipitationChance = precipChance > 0 ? precipChance : nil

                    let precipAmount = dayWeather.precipitationAmountByType.precipitation.converted(to: .millimeters).value
                    model.precipitationIntensity = precipAmount > 0 ? precipAmount : nil

                    // Snowfall (mm)
                    let snowAmount = dayWeather.precipitationAmountByType.snowfallAmount.amount.converted(to: .millimeters).value
                    model.snowfallIntensity = snowAmount > 0 ? snowAmount : nil

                    // UV Index (integer)
                    model.uvIndex = dayWeather.uvIndex.value
                    model.uvIndexCategory = dayWeather.uvIndex.category.description

                    // Date
                    model.date = dayWeather.date
                    model.time = Self.timeFormatter.string(from: dayWeather.date)
                    model.dateTime = Self.dateTimeFormatter.string(from: dayWeather.date)

                    self.dailyForecast.append(model)
                }

                DispatchQueue.main.async {
                    self.delegate?.forecastDataReady(forecast: self.forecast)
                    self.delegate?.dailyForecastDataReady?(forecast: self.dailyForecast)
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.forecastDataNotAvailable?(error: error.localizedDescription)
                }
            }
        }
    }

    /// Returns the last fetched hourly forecast.
    open func getOldForecastData() -> [WeatherModel] {
        return forecast
    }

    /// Returns the last fetched daily forecast.
    open func getOldDailyForecastData() -> [WeatherModel] {
        return dailyForecast
    }

    // MARK: - Formatters

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private static let dateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy - HH:mm:ss"
        return f
    }()
}
