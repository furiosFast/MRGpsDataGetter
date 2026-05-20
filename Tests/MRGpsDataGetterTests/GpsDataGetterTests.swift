import CoreLocation
@testable import MRGpsDataGetter
import XCTest

final class GpsDataGetterTests: XCTestCase, MRGpsDataGetterGpsDataDelegate {
    private var gpsExpectation: XCTestExpectation?
    private var geocodeLocationExpectation: XCTestExpectation?
    private var geocodeStringExpectation: XCTestExpectation?

    private let testLocation = CLLocation(latitude: 41.9028, longitude: 12.4964) // Rome

    // MARK: - Tests

    func testGetPositionInfo() {
        gpsExpectation = expectation(description: "GPS position info ready")

        let getter = GpsDataGetter()
        getter.delegate = self
        getter.getPositionInfo(currentLocation: testLocation)

        waitForExpectations(timeout: 10)

        let gps = getter.getOldGpsData()
        print("=== GPS Position Info ===")
        print("Timestamp: \(String(describing: gps.timestamp))")
        print("Latitude: \(String(describing: gps.latitude))")
        print("Longitude: \(String(describing: gps.longitude))")
        print("Altitude: \(String(describing: gps.altitude))")
        print("Horizontal Accuracy: \(String(describing: gps.horizontalAccuracy))")
        print("Vertical Accuracy: \(String(describing: gps.verticalAccuracy))")
        print("Course: \(String(describing: gps.course))")
        print("Speed (m/s): \(String(describing: gps.speed))")
        print("Speed Accuracy: \(String(describing: gps.speedAccuracy))")
        print("Floor: \(String(describing: gps.floor))")
        print("=========================")

        XCTAssertNotNil(gps.timestamp)
        XCTAssertNotNil(gps.latitude)
        XCTAssertNotNil(gps.longitude)
    }

    func testGetGeocodeFromLocation() {
        geocodeLocationExpectation = expectation(description: "Geocode from location ready")

        let getter = GpsDataGetter()
        getter.delegate = self
        getter.getGeocodeFromLocation(currentLocation: testLocation)

        waitForExpectations(timeout: 15)

        let gps = getter.getOldGpsData()
        print("=== Geocode From Location ===")
        print("Location Name: \(String(describing: gps.locationName))")
        print("=============================")

        XCTAssertNotNil(gps.locationName)
    }

    func testGetGeocodeFromString() {
        geocodeStringExpectation = expectation(description: "Geocode from string ready")

        let getter = GpsDataGetter()
        getter.delegate = self
        getter.getGeocodeFromString(locationAddress: "Rome, Italy")

        waitForExpectations(timeout: 15)
    }

    // MARK: - Delegate

    func gpsDataReady(gps _: GpsInfoModel) {
        gpsExpectation?.fulfill()
    }

    func reverseGeocodeFromLocation(locationName: String) {
        print("Geocode result: \(locationName)")
        geocodeLocationExpectation?.fulfill()
    }

    func reverseGeocodeFromString(location: CLLocation) {
        print("Geocode string result: \(location.coordinate)")
        geocodeStringExpectation?.fulfill()
    }

    func reverseGeocodeFromLocationError(error: String) {
        print("Geocode location error: \(error)")
        geocodeLocationExpectation?.fulfill()
    }

    func reverseGeocodeFromStringError(error: String) {
        print("Geocode string error: \(error)")
        geocodeStringExpectation?.fulfill()
    }
}
