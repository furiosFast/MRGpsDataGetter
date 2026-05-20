import CoreLocation
@testable import MRGpsDataGetter
import XCTest

final class MRGpsDataGetterTests: XCTestCase {
    private let testLocation = CLLocation(latitude: 41.9028, longitude: 12.4964) // Rome

    func testSharedInstance() {
        let instance1 = MRGpsDataGetter.shared
        let instance2 = MRGpsDataGetter.shared
        XCTAssertTrue(instance1 === instance2, "Shared instance should be singleton")
        print("=== Shared Instance ===")
        print("Instance: \(instance1)")
        print("=======================")
    }

    func testPreferencesDefaults() {
        let prefs = MRGpsPreferences()
        print("=== Default Preferences ===")
        print("Speed Unit: \(prefs.speedUnit)")
        print("Show Minutes: \(prefs.showMinutesInTimes)")
        print("Auto Refresh Sun/Moon: \(prefs.autoRefreshSunMoon)")
        print("Refresh Interval: \(prefs.sunMoonRefreshInterval)s")
        print("Use True North: \(prefs.useTrueNorth)")
        print("===========================")

        XCTAssertEqual(prefs.speedUnit, .kilometersPerHour)
        XCTAssertTrue(prefs.showMinutesInTimes)
        XCTAssertFalse(prefs.autoRefreshSunMoon)
        XCTAssertEqual(prefs.sunMoonRefreshInterval, 60)
        XCTAssertTrue(prefs.useTrueNorth)
    }

    func testPreferencesCustom() {
        let prefs = MRGpsPreferences(
            speedUnit: .knots,
            showMinutesInTimes: false,
            autoRefreshSunMoon: true,
            sunMoonRefreshInterval: 30,
            useTrueNorth: false
        )
        print("=== Custom Preferences ===")
        print("Speed Unit: \(prefs.speedUnit)")
        print("Show Minutes: \(prefs.showMinutesInTimes)")
        print("Auto Refresh Sun/Moon: \(prefs.autoRefreshSunMoon)")
        print("Refresh Interval: \(prefs.sunMoonRefreshInterval)s")
        print("Use True North: \(prefs.useTrueNorth)")
        print("==========================")

        XCTAssertEqual(prefs.speedUnit, .knots)
        XCTAssertFalse(prefs.showMinutesInTimes)
        XCTAssertTrue(prefs.autoRefreshSunMoon)
        XCTAssertEqual(prefs.sunMoonRefreshInterval, 30)
        XCTAssertFalse(prefs.useTrueNorth)
    }

    func testSetCurrentLocation() throws {
        let shared = MRGpsDataGetter.shared
        XCTAssertNil(shared.getCurrentLocation())

        shared.setCurrentLocation(testLocation)
        let stored = shared.getCurrentLocation()

        print("=== Set/Get Location ===")
        print("Stored: \(String(describing: stored?.coordinate))")
        print("========================")

        XCTAssertNotNil(stored)
        XCTAssertEqual(try XCTUnwrap(stored?.coordinate.latitude), testLocation.coordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(try XCTUnwrap(stored?.coordinate.longitude), testLocation.coordinate.longitude, accuracy: 0.0001)
    }

    func testGettersAccessible() {
        let shared = MRGpsDataGetter.shared
        print("=== Getters Accessible ===")
        print("GPS: \(shared.getGpsDataGetter())")
        print("Sun: \(shared.getSunDataGetter())")
        print("Moon: \(shared.getMoonDataGetter())")
        print("Weather: \(shared.getWeatherDataGetter())")
        print("Forecast: \(shared.getForecastDataGetter())")
        print("==========================")

        XCTAssertNotNil(shared.getGpsDataGetter())
        XCTAssertNotNil(shared.getSunDataGetter())
        XCTAssertNotNil(shared.getMoonDataGetter())
        XCTAssertNotNil(shared.getWeatherDataGetter())
        XCTAssertNotNil(shared.getForecastDataGetter())
    }

    func testSpeedUnitEnum() {
        print("=== SpeedUnit Enum ===")
        print("metersPerSecond rawValue: \(SpeedUnit.metersPerSecond.rawValue)")
        print("kilometersPerHour rawValue: \(SpeedUnit.kilometersPerHour.rawValue)")
        print("knots rawValue: \(SpeedUnit.knots.rawValue)")
        print("milesPerHour rawValue: \(SpeedUnit.milesPerHour.rawValue)")
        print("======================")

        XCTAssertEqual(SpeedUnit.metersPerSecond.rawValue, "meterSecondSpeed")
        XCTAssertEqual(SpeedUnit.kilometersPerHour.rawValue, "kilometerHoursSpeed")
        XCTAssertEqual(SpeedUnit.knots.rawValue, "knotSpeed")
        XCTAssertEqual(SpeedUnit.milesPerHour.rawValue, "milesHoursSpeed")
    }
}
