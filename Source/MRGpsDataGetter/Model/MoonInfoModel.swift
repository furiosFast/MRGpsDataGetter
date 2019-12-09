//
//  LunaModel.swift
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

public class MoonInfoModel: NSObject { 
    
    public final var altitude : String = loc("NOTAVAILABLENUMBER")
    public final var fractionOfMoonIlluminated : String = loc("NOTAVAILABLENUMBER")
    public final var azimuth : String = loc("NOTAVAILABLENUMBER")
    public final var distance : String = loc("NOTAVAILABLENUMBER")
    
    public final var declination : String = loc("NOTAVAILABLENUMBER")
    public final var rightAscension : String = loc("NOTAVAILABLENUMBER")
    public final var zodiacSign : String = loc("NOTAVAILABLENUMBER")
    public final var age : String = loc("NOTAVAILABLENUMBER")

    public final var moonRise : String = loc("NOTAVAILABLENUMBER")
    public final var moonSet : String = loc("NOTAVAILABLENUMBER")
    
    public final var phase : String = loc("NOTAVAILABLENUMBER")
    public final var phaseIcon : String = loc("NOTAVAILABLENUMBER")
    public final var phaseTitle : String = loc("NOTAVAILABLENUMBER")
    public final var phaseAngle : String = loc("NOTAVAILABLENUMBER")

    public final var horizontalPosition : String = loc("NOTAVAILABLENUMBER")
    
    public final var moonTilt : String = loc("NOTAVAILABLENUMBER")
    public final var trajectory : String = loc("NOTAVAILABLENUMBER")
    
    public final var moonNoon : String = loc("NOTAVAILABLENUMBER")
    public final var nadir : String = loc("NOTAVAILABLENUMBER")
    
    public final var previusEclipse: Eclipse?
    public final var nextEclipse: Eclipse?

}
