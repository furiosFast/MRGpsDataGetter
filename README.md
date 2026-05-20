# MRGpsDataGetter

[![SPM ready](https://img.shields.io/badge/SPM-ready-orange.svg)](https://swift.org/package-manager/)
![Platform](https://img.shields.io/badge/platforms-iOS%2018.0%20%7C%20tvOS%2018.0%20%7C%20watchOS%2011.0-F28D00.svg)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-16.0-blue.svg)](https://developer.apple.com/xcode)
[![License](https://img.shields.io/cocoapods/l/Pastel.svg?style=flat)](https://github.com/furiosFast/MRGpsDataGetter/blob/master/LICENSE)

Easy access to Sun, Moon, Location, Weather and Forecast data. Weather data is provided by Apple WeatherKit (hourly + 10-day daily forecast, alerts, UV index, and more).

## Requirements

- iOS 18.0+ / tvOS 18.0+ / watchOS 11.0+
- Xcode 16.0+
- Swift 6.0+
- Apple Developer Program membership (for WeatherKit entitlement)

## Setup

1. Enable **WeatherKit** capability in your Xcode project (Signing & Capabilities)
2. Enable **WeatherKit** in your App ID on the Apple Developer Portal
3. Wait up to 30 minutes for propagation

## Installation

### Swift Package Manager

Add MRGpsDataGetter as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/furiosFast/MRGpsDataGetter.git", from: "2.0.0")
]
```

## Usage

### Initialization

```swift
import MRGpsDataGetter

// Configure preferences
MRGpsDataGetter.shared.preferences = MRGpsPreferences(
    speedUnit: .kilometersPerHour,
    showMinutesInTimes: true,
    autoRefreshSunMoon: true,
    sunMoonRefreshInterval: 60,
    useTrueNorth: true
)

// Set delegates
MRGpsDataGetter.shared.delegate = self
MRGpsDataGetter.shared.weatherDataGetter.delegate = self
MRGpsDataGetter.shared.forecastDataGetter.delegate = self
MRGpsDataGetter.shared.sunDataGetter.delegate = self
MRGpsDataGetter.shared.moonDataGetter.delegate = self
MRGpsDataGetter.shared.gpsDataGetter.delegate = self

// Start fetching all data
MRGpsDataGetter.shared.refreshAllData()
```

### Weather Data

Weather data is returned as raw values (no formatting, no localization). The app client is responsible for formatting and unit conversion.

```swift
func weatherDataReady(weather: WeatherModel) {
    if let temp = weather.temp {
        print("Temperature: \(temp)°C")
    }
    if let wind = weather.windSpeed {
        print("Wind: \(wind) m/s")
    }
    if let pressure = weather.pressure {
        print("Pressure: \(pressure) hPa")
    }
    if let symbol = weather.weatherSymbolName {
        let image = UIImage(systemName: symbol)
    }
}
```

### Forecast Data

Hourly and daily forecasts are delivered separately via delegate:

```swift
func forecastDataReady(forecast: [WeatherModel]) {
    // Hourly forecast array
    for hour in forecast {
        print("\(hour.time ?? "") - \(hour.temp ?? 0)°C")
    }
}

func dailyForecastDataReady(forecast: [WeatherModel]) {
    // 10-day daily forecast
    for day in forecast {
        print("\(day.dateTime ?? "") - \(day.tempMin ?? 0)°C / \(day.tempMax ?? 0)°C")
    }
}
```

### Weather Alerts

```swift
func weatherAlertsReady(alerts: [WeatherAlertModel]) {
    for alert in alerts {
        print("[\(alert.severity)] \(alert.summary)")
    }
}
```

### Sun & Moon Data

```swift
func sunDataReady(sun: SunInfoModel) {
    print("Sunrise: \(sun.sunriseStart ?? "")")
    print("Sunset: \(sun.sunsetStart ?? "")")
    print("Zodiac: \(sun.zodiacSign ?? "")")
}

func moonDataReady(moon: MoonInfoModel) {
    print("Moon rise: \(moon.moonRise ?? "")")
    print("Phase: \(moon.phaseTitle ?? "")")
    print("Illumination: \(moon.fractionOfMoonIlluminated ?? "")%")
}
```

### Apple Weather Attribution (required)

You **must** display Apple Weather attribution in your app:

```swift
Task {
    let attribution = try await MRGpsDataGetter.shared.getWeatherAttribution()
    // Display attribution.combinedMarkDarkURL or attribution.combinedMarkLightURL
    // Link to attribution.legalPageURL
}
```

## Data Units

All weather data is returned in SI base units:

| Field | Unit |
|-------|------|
| Temperature | Celsius (°C) |
| Wind speed | m/s |
| Pressure | hPa |
| Visibility | km |
| Precipitation | mm or mm/h |
| Humidity | 0-1 (fraction) |
| Cloud cover | 0-1 (fraction) |
| Wind direction | degrees (°) |
| UV Index | integer |

## Localization

The library includes localized strings for 14 languages:
English, Italian, German, Spanish, French, Japanese, Korean, Portuguese (Brazil), Chinese Simplified, Chinese Traditional, Dutch, Russian, Arabic, Polish.

Localized content includes: cardinal directions, wind names, moon phases, zodiac signs, sun/moon position descriptions.

## Testing

```bash
xcodebuild test -scheme MRGpsDataGetter \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

## Dependencies

Managed automatically via SPM:
- [SwifterSwift](https://github.com/SwifterSwift/SwifterSwift) 8.0.0+
- [ESDateHelper](https://github.com/eskaria/ESDateHelper) 1.1.0+
- [EKAstrologyCalc](https://github.com/emvakar/EKAstrologyCalc) 1.0.6+

Bundled sources:
- [BDAstroCalc](https://github.com/braindrizzlestudio/BDAstroCalc)
- [SunMoonCalculator](https://github.com/kanchudeep/SunMoonCalculator)

## License

MRGpsDataGetter is released under the MIT license. See [LICENSE](https://github.com/furiosFast/MRGpsDataGetter/blob/master/LICENSE) for more information.
