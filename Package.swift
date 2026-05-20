// swift-tools-version:6.0
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
        .iOS(.v18), .tvOS(.v18), .watchOS(.v11),
    ],
    products: [
        .library(name: "MRGpsDataGetter", targets: ["MRGpsDataGetter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", from: "8.0.0"),
        .package(url: "https://github.com/eskaria/ESDateHelper.git", from: "1.1.0"),
        .package(url: "https://github.com/emvakar/EKAstrologyCalc.git", from: "1.0.6"),
    ],
    targets: [
        .target(
            name: "MRGpsDataGetter",
            dependencies: ["SwifterSwift", "ESDateHelper", "EKAstrologyCalc"],
            resources: [.process("Resources")],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "MRGpsDataGetterTests",
            dependencies: ["MRGpsDataGetter"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
