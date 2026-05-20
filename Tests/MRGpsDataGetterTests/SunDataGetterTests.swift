import CoreLocation
@testable import MRGpsDataGetter
import XCTest

final class SunDataGetterTests: XCTestCase, MRGpsDataGetterSunDataDelegate {
    private var sunExpectation: XCTestExpectation?

    private let testLocation = CLLocation(latitude: 41.9028, longitude: 12.4964) // Rome

    func testGetSunInfo() {
        sunExpectation = expectation(description: "Sun data ready")

        MRGpsDataGetter.shared.preferences.showMinutesInTimes = true

        let getter = SunDataGetter()
        getter.delegate = self
        getter.getSunInfo(currentLocation: testLocation)

        waitForExpectations(timeout: 10)

        let sun = getter.getOldSunData()
        print("=== Sun Info ===")
        print("Timestamp: \(String(describing: sun.timestamp))")
        print("Sunrise Start: \(String(describing: sun.sunriseStart))")
        print("Sunrise End: \(String(describing: sun.sunriseEnd))")
        print("Sunset Start: \(String(describing: sun.sunsetStart))")
        print("Sunset End: \(String(describing: sun.sunsetEnd))")
        print("Solar Noon: \(String(describing: sun.solarNoon))")
        print("Nadir: \(String(describing: sun.nadir))")
        print("Altitude: \(String(describing: sun.altitude))")
        print("Azimuth: \(String(describing: sun.azimuth))")
        print("Declination: \(String(describing: sun.declination))")
        print("Right Ascension: \(String(describing: sun.rightAscension))")
        print("Zodiac Sign: \(String(describing: sun.zodiacSign))")
        print("Phase Title: \(String(describing: sun.phaseTitle))")
        print("Horizontal Position: \(String(describing: sun.horizontalPosition))")
        print("Distance: \(String(describing: sun.distance))")
        print("Daylight Hours: \(String(describing: sun.daylightHours))")
        print("Astronomical Dusk Sunrise: \(String(describing: sun.astronomicalDuskSunrise))")
        print("Nautical Dusk Sunrise: \(String(describing: sun.nauticalDuskSunrise))")
        print("Civil Dusk Sunrise: \(String(describing: sun.civilDuskSunrise))")
        print("Golden Hour Sunrise: \(String(describing: sun.goldenHourSunriseStart)) - \(String(describing: sun.goldenHourSunriseEnd))")
        print("Golden Hour Sunset: \(String(describing: sun.goldenHourSunsetStart)) - \(String(describing: sun.goldenHourSunsetEnd))")
        print("Blue Hour Sunrise: \(String(describing: sun.blueHourSunriseStart)) - \(String(describing: sun.blueHourSunriseEnd))")
        print("Blue Hour Sunset: \(String(describing: sun.blueHourSunsetStart)) - \(String(describing: sun.blueHourSunsetEnd))")
        print("================")

        XCTAssertNotNil(sun.timestamp)
        XCTAssertNotNil(sun.sunriseStart)
        XCTAssertNotNil(sun.sunsetStart)
        XCTAssertNotNil(sun.altitude)
    }

    // MARK: - Delegate

    func sunDataReady(sun _: SunInfoModel) {
        sunExpectation?.fulfill()
    }
}
