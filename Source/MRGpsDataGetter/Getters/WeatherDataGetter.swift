//
//  WeatherDataGetter.swift
//  MRGpsDataGetter
//
//  Created by Marco Ricca on 20/11/2019
//  Copyright © 2019 Fast-Devs Project. All rights reserved.
//

import CoreLocation
import UIKit
import WeatherKit

@objc public protocol MRGpsDataGetterWeatherDataDelegate: NSObjectProtocol {
    /// Called when current weather data is ready.
    func weatherDataReady(weather: WeatherModel)
    /// Called when weather data cannot be retrieved.
    @objc optional func weatherDataNotAvailable(error: String)
    /// Called when weather alerts are available for the location.
    @objc optional func weatherAlertsReady(alerts: [WeatherAlertModel])
}

/// Fetches current weather data via Apple WeatherKit.
/// All values are returned in SI units: temperature in °C, wind in m/s, pressure in hPa, visibility in km.
open class WeatherDataGetter: NSObject, @unchecked Sendable {
    open weak var delegate: MRGpsDataGetterWeatherDataDelegate?

    private let weather = WeatherModel()
    private let weatherService = WeatherService.shared

    /// Fetches current weather + today's daily forecast for min/max temps.
    /// Results delivered via delegate on the main thread.
    open func getWeatherInfo(currentLocation: CLLocation) {
        Task {
            do {
                let weatherData = try await weatherService.weather(for: currentLocation)
                let current = weatherData.currentWeather

                weather.timestamp = Date()
                weather.currentWeatherLocation = currentLocation

                // Condition & SF Symbol
                weather.weatherCondition = current.condition.rawValue
                weather.weatherDescription = current.condition.description
                weather.weatherSymbolName = current.symbolName
                weather.isDaylight = current.isDaylight

                // Wind speed (m/s), gust (m/s), direction (degrees)
                let windSpeedMS = current.wind.speed.converted(to: .metersPerSecond).value
                weather.windSpeed = windSpeedMS
                weather.windSpeedGust = current.wind.gust?.converted(to: .metersPerSecond).value

                let windAngle = current.wind.direction.converted(to: .degrees).value
                weather.windDegree = windAngle
                weather.windName = getWindName(windAngle)

                // Beaufort scale (0-12 integer + hex color)
                let windKnot = windSpeedMS * meterSecondToKnot
                weather.beaufortScaleWindSpeed = Int(getBeaufortForce(windKnot)) ?? 0
                weather.beaufortScaleWindColourForWindSpeed = getBeaufortForceColor(windKnot)

                if let gustMS = weather.windSpeedGust {
                    let gustKnot = gustMS * meterSecondToKnot
                    weather.beaufortScaleWindSpeedGust = Int(getBeaufortForce(gustKnot)) ?? 0
                    weather.beaufortScaleWindColourForWindSpeedGust = getBeaufortForceColor(gustKnot)
                }

                // Precipitation intensity (mm/h), nil if none
                let precipIntensity = current.precipitationIntensity.value
                weather.precipitationIntensity = precipIntensity > 0 ? precipIntensity : nil

                // Visibility (km)
                weather.visibility = current.visibility.converted(to: .kilometers).value

                // Pressure (hPa) and trend
                weather.pressure = current.pressure.converted(to: .hectopascals).value
                switch current.pressureTrend {
                case .rising: weather.pressureTrend = "rising"
                case .falling: weather.pressureTrend = "falling"
                case .steady: weather.pressureTrend = "steady"
                @unknown default: weather.pressureTrend = nil
                }

                // Humidity (0-1 fraction)
                weather.humidity = current.humidity

                // Temperature (°C)
                weather.temp = current.temperature.converted(to: .celsius).value
                weather.feelsLike = current.apparentTemperature.converted(to: .celsius).value

                // Min/Max from today's daily forecast (°C)
                if let today = weatherData.dailyForecast.first {
                    weather.tempMin = today.lowTemperature.converted(to: .celsius).value
                    weather.tempMax = today.highTemperature.converted(to: .celsius).value
                }

                // UV Index (integer) and category description
                weather.uvIndex = current.uvIndex.value
                weather.uvIndexCategory = current.uvIndex.category.description

                // Dew point (°C)
                weather.dewPoint = current.dewPoint.converted(to: .celsius).value

                // Cloud cover (0-1 fraction), nil if clear
                let cloudCover = current.cloudCover
                weather.clouds = cloudCover > 0 ? cloudCover : nil

                // Weather alerts
                let alerts: [WeatherAlertModel] = weatherData.weatherAlerts?.map { alert in
                    let model = WeatherAlertModel()
                    model.summary = alert.summary
                    model.source = alert.source
                    model.detailsURL = alert.detailsURL
                    if let region = alert.region {
                        model.affectedRegions = [region]
                    }
                    switch alert.severity {
                    case .minor: model.severity = "minor"
                    case .moderate: model.severity = "moderate"
                    case .severe: model.severity = "severe"
                    case .extreme: model.severity = "extreme"
                    default: model.severity = "unknown"
                    }
                    return model
                } ?? []

                DispatchQueue.main.async {
                    self.delegate?.weatherDataReady(weather: self.weather)
                    if !alerts.isEmpty {
                        self.delegate?.weatherAlertsReady?(alerts: alerts)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.weatherDataNotAvailable?(error: error.localizedDescription)
                }
            }
        }
    }

    /// Returns the last fetched weather data.
    open func getOldWeatherData() -> WeatherModel {
        return weather
    }
}
