import CoreLocation
@testable import MRGpsDataGetter
import XCTest

final class WeatherDataGetterTests: XCTestCase, MRGpsDataGetterWeatherDataDelegate {
    private var weatherExpectation: XCTestExpectation?
    private var alertsExpectation: XCTestExpectation?
    private var errorMessage: String?

    private let testLocation = CLLocation(latitude: 41.9028, longitude: 12.4964) // Rome

    func testGetWeatherInfo() {
        weatherExpectation = expectation(description: "Weather data ready")

        let getter = WeatherDataGetter()
        getter.delegate = self
        getter.getWeatherInfo(currentLocation: testLocation)

        waitForExpectations(timeout: 30)

        if let error = errorMessage {
            print("⚠️ Weather not available (expected without WeatherKit entitlement): \(error)")
            return
        }

        let weather = getter.getOldWeatherData()
        print("=== Weather Info ===")
        print("Timestamp: \(String(describing: weather.timestamp))")
        print("Condition: \(String(describing: weather.weatherCondition))")
        print("Description: \(String(describing: weather.weatherDescription))")
        print("SF Symbol: \(String(describing: weather.weatherSymbolName))")
        print("Is Daylight: \(String(describing: weather.isDaylight))")
        print("--- Temperature (°C) ---")
        print("Current: \(String(describing: weather.temp))")
        print("Feels Like: \(String(describing: weather.feelsLike))")
        print("Min: \(String(describing: weather.tempMin))")
        print("Max: \(String(describing: weather.tempMax))")
        print("Dew Point: \(String(describing: weather.dewPoint))")
        print("--- Wind (m/s) ---")
        print("Speed: \(String(describing: weather.windSpeed))")
        print("Gust: \(String(describing: weather.windSpeedGust))")
        print("Direction (°): \(String(describing: weather.windDegree))")
        print("Direction Name: \(String(describing: weather.windName))")
        print("Beaufort: \(String(describing: weather.beaufortScaleWindSpeed))")
        print("Beaufort Color: \(String(describing: weather.beaufortScaleWindColourForWindSpeed))")
        print("--- Atmosphere ---")
        print("Pressure (hPa): \(String(describing: weather.pressure))")
        print("Pressure Trend: \(String(describing: weather.pressureTrend))")
        print("Humidity (0-1): \(String(describing: weather.humidity))")
        print("Visibility (km): \(String(describing: weather.visibility))")
        print("Cloud Cover (0-1): \(String(describing: weather.clouds))")
        print("--- Precipitation ---")
        print("Intensity (mm/h): \(String(describing: weather.precipitationIntensity))")
        print("--- UV ---")
        print("UV Index: \(String(describing: weather.uvIndex))")
        print("UV Category: \(String(describing: weather.uvIndexCategory))")
        print("====================")

        XCTAssertNotNil(weather.timestamp)
        XCTAssertNotNil(weather.temp)
        XCTAssertNotNil(weather.windSpeed)
        XCTAssertNotNil(weather.pressure)
        XCTAssertNotNil(weather.humidity)
        XCTAssertNotNil(weather.weatherSymbolName)
    }

    // MARK: - Delegate

    func weatherDataReady(weather _: WeatherModel) {
        weatherExpectation?.fulfill()
    }

    func weatherDataNotAvailable(error: String) {
        errorMessage = error
        weatherExpectation?.fulfill()
    }

    func weatherAlertsReady(alerts: [WeatherAlertModel]) {
        print("=== Weather Alerts ===")
        for alert in alerts {
            print("[\(alert.severity)] \(alert.summary) - Source: \(alert.source)")
            print("  URL: \(String(describing: alert.detailsURL))")
            print("  Regions: \(alert.affectedRegions)")
        }
        print("======================")
    }
}
