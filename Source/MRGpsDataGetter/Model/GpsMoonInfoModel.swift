//
//  LunaModel.swift
//  iWindRose²
//
//  Created by Marco on 17/04/18.
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
//

import UIKit

public final class GpsMoonInfoModel: NSObject { 
    
    public final var altitude : String = loc("NOTAVAIABLENUMBER")
    public final var fractionOfMoonIlluminated : String = loc("NOTAVAIABLENUMBER")
    public final var azimuth : String = loc("NOTAVAIABLENUMBER")
    public final var distance : String = loc("NOTAVAIABLENUMBER")
    
    public final var declination : String = loc("NOTAVAIABLENUMBER")
    public final var rightAscension : String = loc("NOTAVAIABLENUMBER")
    public final var zodiacSign : String = loc("NOTAVAIABLENUMBER")
    
    public final var moonRise : String = loc("NOTAVAIABLENUMBER")
    public final var moonSet : String = loc("NOTAVAIABLENUMBER")
    
    public final var phaseIcon : String = loc("NOTAVAIABLENUMBER")
    public final var phaseTitle : String = loc("NOTAVAIABLENUMBER")
    public final var phaseAngle : String = loc("NOTAVAIABLENUMBER")

    public final var horizontalPosition : String = loc("NOTAVAIABLENUMBER")
    
    public final var moonTilt : String = loc("NOTAVAIABLENUMBER")
    
}
