// swift-tools-version:5.3
//
//  Package.swift
//  MRGpsDataGetter
//
//  Created by Marco Ricca on 20/11/2019
//
//  Created for MRGpsDataGetter in 20/11/2019
//  Using Swift 5.0
//  Running on macOS 10.14
//
//  Copyright © 2019 Fast-Devs Project. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "MRGpsDataGetter",
    defaultLocalization: "en",
    platforms: [
        // Some platform where run yours library
        .iOS(.v11), .tvOS(.v11), .watchOS(.v4)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "MRGpsDataGetter", targets: ["MRGpsDataGetter"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0-rc.3"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", from: "5.1.0"),
        .package(url: "https://github.com/emvakar/EKAstrologyCalc.git", from: "1.0.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "MRGpsDataGetter", dependencies: ["Alamofire", "SwiftyJSON", "SwifterSwift", "EKAstrologyCalc"], resources: [.process("Resources/lamma logo.png")]),
//        .target(name: "MRGpsDataGetter"),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
