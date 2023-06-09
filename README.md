# MRGpsDataGetter

[![SPM ready](https://img.shields.io/badge/SPM-ready-orange.svg)](https://swift.org/package-manager/)
![Platform](https://img.shields.io/badge/platforms-iOS%2011.0%20%7C%20tvOS%2011.0%20%7C%20watchOS%204.0-F28D00.svg)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-12.0-blue.svg)](https://developer.apple.com/xcode)
[![License](https://img.shields.io/cocoapods/l/Pastel.svg?style=flat)](https://github.com/furiosFast/MRGpsDataGetter/blob/master/LICENSE)
[![Twitter](https://img.shields.io/badge/twitter-@FastDevsProject-blue.svg?style=flat)](https://twitter.com/FastDevsProject)

Easy access to Sun, Moon and Location informations. In addition Weather and 5 day/3 hour Forecast (5 day/3 hour through the OpenWeatherMap.org provider).

## Requirements

- iOS 13.0+ / tvOS 13.0+ / watchOS 6.1+
- Xcode 12.0+
- Swift 5+

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but MRGpsDataGetter does support its use on supported platforms.

Once you have your Swift package set up, adding MRGpsDataGetter as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/furiosFast/MRGpsDataGetter.git", from: "1.0.0")
]
```

## Usage

### Initialization

```swift
import MRGpsDataGetter
```

## Requirements

MRGpsDataGetter has different dependencies and therefore needs the following libraries (also available via SPM):
- [Alamofie](https://github.com/Alamofire/Alamofire) 5.0.0-rc.3+
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) 5.0.0+
- [SwifterSwift](https://github.com/SwifterSwift/SwifterSwift) 5.1.0+

It isn't necessary to add the dependencies of MRGpsDataGetter, becose with SPM all is do automatically!

Others library's files are necessary for the correct functioning of MRGpsDataGetter:
- [BDAstroCalc](https://github.com/braindrizzlestudio/BDAstroCalc)
- [AstrologyCalc](https://github.com/emvakar/AstrologyCalc)
- [SunMoonCalculator](https://github.com/kanchudeep/SunMoonCalculator)
- [EKAstrologyCalc](https://github.com/emvakar/EKAstrologyCalc)

There files are already included into the framework.

## License

MRGpsDataGetter is released under the MIT license. See [LICENSE](https://github.com/furiosFast/MRGpsDataGetter/blob/master/LICENSE) for more information.
