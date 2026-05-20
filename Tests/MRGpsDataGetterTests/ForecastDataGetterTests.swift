import CoreLocation
@testable import MRGpsDataGetter
import XCTest

final class ForecastDataGetterTests: XCTestCase, MRGpsDataGetterForecastDataDelegate {
    private var forecastExpectation: XCTestExpectation?
    private var dailyExpectation: XCTestExpectation?
    private var errorMessage: String?

    private let testLocation = CLLocation(latitude: 41.9028, longitude: 12.4964) // Rome

    func testGetForecastInfo() {
        forecastExpectation = expectation(description: "Forecast data ready")
        dailyExpectation = expectation(description: "Daily forecast data ready")
        dailyExpectation?.isInverted = false

        let getter = ForecastDataGetter()
        getter.delegate = self
        getter.getForecastInfo(currentLocation: testLocation)

        waitForExpectations(timeout: 30)

        if let error = errorMessage {
            print("⚠️ Forecast not available (expected without WeatherKit entitlement): \(error)")
            return
        }

        let hourly = getter.getOldForecastData()
        let daily = getter.getOldDailyForecastData()

        print("=== Hourly Forecast (\(hourly.count) entries) ===")
        for (i, h) in hourly.prefix(5).enumerated() {
            print("[\(i)] \(h.time ?? "-") | \(String(describing: h.weatherDescription)) | \(String(format: "%.1f", h.temp ?? 0))°C | Wind: \(String(format: "%.1f", h.windSpeed ?? 0)) m/s | Clouds: \(String(describing: h.clouds))")
        }
        if hourly.count > 5 {
            print("... and \(hourly.count - 5) more entries")
        }

        print("\n=== Daily Forecast (\(daily.count) entries) ===")
        for (i, d) in daily.enumerated() {
            print("[\(i)] \(d.dateTime ?? "-") | \(String(describing: d.weatherDescription))")
            print("     Temp: \(String(format: "%.1f", d.tempMin ?? 0)) - \(String(format: "%.1f", d.tempMax ?? 0))°C")
            print("     Wind: \(String(format: "%.1f", d.windSpeed ?? 0)) m/s \(d.windName ?? "")")
            print("     Precip chance: \(String(describing: d.precipitationChance))")
            print("     Precip amount (mm): \(String(describing: d.precipitationIntensity))")
            print("     Snow (mm): \(String(describing: d.snowfallIntensity))")
            print("     UV: \(String(describing: d.uvIndex))")
        }

        XCTAssertFalse(hourly.isEmpty, "Hourly forecast should not be empty")
        XCTAssertFalse(daily.isEmpty, "Daily forecast should not be empty")

        if let first = hourly.first {
            XCTAssertNotNil(first.temp)
            XCTAssertNotNil(first.windSpeed)
            XCTAssertNotNil(first.weatherSymbolName)
        }
    }

    // MARK: - Delegate

    func forecastDataReady(forecast _: [WeatherModel]) {
        forecastExpectation?.fulfill()
    }

    func dailyForecastDataReady(forecast _: [WeatherModel]) {
        dailyExpectation?.fulfill()
    }

    func forecastDataNotAvailable(error: String) {
        errorMessage = error
        forecastExpectation?.fulfill()
        dailyExpectation?.fulfill()
    }
}
