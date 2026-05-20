import CoreLocation
@testable import MRGpsDataGetter
import XCTest

final class MoonDataGetterTests: XCTestCase, MRGpsDataGetterMoonDataDelegate {
    private var moonExpectation: XCTestExpectation?

    private let testLocation = CLLocation(latitude: 41.9028, longitude: 12.4964) // Rome

    func testGetMoonInfo() {
        moonExpectation = expectation(description: "Moon data ready")

        MRGpsDataGetter.shared.preferences.showMinutesInTimes = true

        let getter = MoonDataGetter()
        getter.delegate = self
        getter.getMoonInfo(currentLocation: testLocation)

        waitForExpectations(timeout: 10)

        let moon = getter.getOldMoonData()
        print("=== Moon Info ===")
        print("Timestamp: \(String(describing: moon.timestamp))")
        print("Moon Rise: \(String(describing: moon.moonRise))")
        print("Moon Set: \(String(describing: moon.moonSet))")
        print("Moon Noon: \(String(describing: moon.moonNoon))")
        print("Nadir: \(String(describing: moon.nadir))")
        print("Altitude: \(String(describing: moon.altitude))")
        print("Azimuth: \(String(describing: moon.azimuth))")
        print("Distance: \(String(describing: moon.distance))")
        print("Phase: \(String(describing: moon.phase))")
        print("Phase Title: \(String(describing: moon.phaseTitle))")
        print("Phase Angle: \(String(describing: moon.phaseAngle))")
        print("Fraction Illuminated: \(String(describing: moon.fractionOfMoonIlluminated))")
        print("Zodiac Sign: \(String(describing: moon.zodiacSign))")
        print("Age: \(String(describing: moon.age))")
        print("Declination: \(String(describing: moon.declination))")
        print("Right Ascension: \(String(describing: moon.rightAscension))")
        print("Horizontal Position: \(String(describing: moon.horizontalPosition))")
        print("Moon Tilt: \(String(describing: moon.moonTilt))")
        print("Trajectory: \(String(describing: moon.trajectory))")
        print("Previous Eclipse: \(String(describing: moon.previusEclipse))")
        print("Next Eclipse: \(String(describing: moon.nextEclipse))")
        print("=================")

        XCTAssertNotNil(moon.timestamp)
        XCTAssertNotNil(moon.moonRise)
        XCTAssertNotNil(moon.phase)
        XCTAssertNotNil(moon.zodiacSign)
    }

    // MARK: - Delegate

    func moonDataReady(moon _: MoonInfoModel) {
        moonExpectation?.fulfill()
    }
}
