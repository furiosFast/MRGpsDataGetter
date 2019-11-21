//
//  LunaModel.swift
//  iWindRose²
//
//  Created by Marco on 17/04/18.
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
//

import UIKit

public final class GpsMoonInfoModel: NSObject {
    
    public final var altitudine : String = loc("NOTAVAIABLENUMBER")
    public final var illuminazioneLunare : String = loc("NOTAVAIABLENUMBER")
    public final var azimuth : String = loc("NOTAVAIABLENUMBER")
    public final var distanzaTerraLuna : String = loc("NOTAVAIABLENUMBER")
    
    public final var declinazione : String = loc("NOTAVAIABLENUMBER")
    public final var rettaAscendente : String = loc("NOTAVAIABLENUMBER")
    public final var segnoZodiacale : String = loc("NOTAVAIABLENUMBER")
    public final var phaseAngle : String = loc("NOTAVAIABLENUMBER")
    
    
    public final var alba : String = loc("NOTAVAIABLENUMBER")
    public final var tramonto : String = loc("NOTAVAIABLENUMBER")
    
    public final var iconaFaseLunare : String = loc("NOTAVAIABLENUMBER")
    public final var titoloFaseLunare : String = loc("NOTAVAIABLENUMBER")
    
    public final var posizioneOrizzonte : String = loc("NOTAVAIABLENUMBER")
    
    public final var angoloOmbra : String = loc("NOTAVAIABLENUMBER")
    
}
