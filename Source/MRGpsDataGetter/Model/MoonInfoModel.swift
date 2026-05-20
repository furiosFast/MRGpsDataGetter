//
//  MoonInfoModel.swift
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

import EKAstrologyCalc
import UIKit

public class MoonInfoModel: NSObject {
    public final var timestamp: Date?

    public final var altitude: String?
    public final var fractionOfMoonIlluminated: String?
    public final var azimuth: String?
    public final var distance: String?

    public final var declination: String?
    public final var rightAscension: String?
    public final var zodiacSign: String?
    public final var age: String?

    public final var moonRise: String?
    public final var moonSet: String?

    public final var phase: String?
    public final var phaseIcon: UIImage = .init(named: "moon", in: .module, with: nil)!
    public final var phaseTitle: String?
    public final var phaseAngle: String?

    public final var horizontalPosition: String?

    public final var moonTilt: String?
    public final var trajectory: String?

    public final var moonNoon: String?
    public final var nadir: String?

    public final var previusEclipse: EKEclipse?
    public final var nextEclipse: EKEclipse?
}
