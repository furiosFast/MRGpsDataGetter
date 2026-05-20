//
//  GpsInfoModel.swift
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

import UIKit

public class GpsInfoModel: NSObject {
    public final var timestamp: Date?

    public final var locationName: String?

    public final var latitude: String?
    public final var longitude: String?
    public final var horizontalAccuracy: String?
    public final var altitude: String?
    public final var verticalAccuracy: String?
    public final var course: String?
    public final var courseAccuracy: String?
    public final var speed: String?
    public final var speedAccuracy: String?
    public final var floor: String?
}
