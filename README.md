# MRGpsDataGetter

![Platform](https://img.shields.io/badge/platforms-iOS%2011.0%20%7C%20macOS%2010.11%20%7C%20tvOS%2011.0%20%7C%20watchOS%204.0-F28D00.svg)

Easy access to Sun, Moon and Location informations. In addition Weather and Future Forecasts.

## Requirements

- iOS 11.0+ / macOS 10.11+ / tvOS 11.0+ / watchOS 4.0+
- Xcode 10.2+
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

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate MRGpsDataGetter into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

  ```bash
  $ git init
  ```

- Add MRGpsDataGetter as a git [submodule](https://git-scm.com/docs/git-submodule) by running the following command:

  ```bash
  $ git submodule add https://github.com/furiosfast/MRGpsDataGetter.git
  ```

- Open the new `MRGpsDataGetter` folder, and drag the `MRGpsDataGetter.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `MRGpsDataGetter.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `MRGpsDataGetter.xcodeproj` folders each with two different versions of the `MRGpsDataGetter.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from, but it does matter whether you choose the top or bottom `MRGpsDataGetter.framework`.

- And that's it!

  > The `MRGpsDataGetter.framework` is automatically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

## Usage

### Initialization

```swift
import MRGpsDataGetter
```

## Requirements

MRGpsDataGetter has different dependencies and therefore needs the following libraries (also available via SPM):
- [Alamofie](https://github.com/Alamofire/Alamofire) 5.0.0-rc.3 +
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) 5.0.0+
- [SwifterSwift](https://github.com/SwifterSwift/SwifterSwift) 5.1.0+

Adding MRGpsDataGetter to your project (with SPM) will cause the related dependencies to be added.

## License

SwifterSwift is released under the MIT license. See [LICENSE](https://github.com/furiosFast/MRGpsDataGetter/blob/master/LICENSE) for more information.
