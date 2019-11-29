//
//  LunaModel.swift
//  iWindRose²
//
//  Created by Marco on 17/04/18.
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
//

import UIKit

public final class GpsMoonInfoModel: NSObject { 
    
    public final var altitude : String = loc("NOTAVAILABLENUMBER")
    public final var fractionOfMoonIlluminated : String = loc("NOTAVAILABLENUMBER")
    public final var azimuth : String = loc("NOTAVAILABLENUMBER")
    public final var distance : String = loc("NOTAVAILABLENUMBER")
    
    public final var declination : String = loc("NOTAVAILABLENUMBER")
    public final var rightAscension : String = loc("NOTAVAILABLENUMBER")
    public final var zodiacSign : String = loc("NOTAVAILABLENUMBER")
    
    public final var moonRise : String = loc("NOTAVAILABLENUMBER")
    public final var moonSet : String = loc("NOTAVAILABLENUMBER")
    
    public final var phaseIcon : String = loc("NOTAVAILABLENUMBER")
    public final var phaseTitle : String = loc("NOTAVAILABLENUMBER")
    public final var phaseAngle : String = loc("NOTAVAILABLENUMBER")

    public final var horizontalPosition : String = loc("NOTAVAILABLENUMBER")
    
    public final var moonTilt : String = loc("NOTAVAILABLENUMBER")
    
}
