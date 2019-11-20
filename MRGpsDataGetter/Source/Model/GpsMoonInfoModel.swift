//
//  LunaModel.swift
//  iWindRose²
//
//  Created by Marco on 17/04/18.
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
//

import UIKit

class GpsMoonInfoModel: NSObject {
    
    var altitudine : String = loc("NOTAVAIABLENUMBER")
    var illuminazioneLunare : String = loc("NOTAVAIABLENUMBER")
    var azimuth : String = loc("NOTAVAIABLENUMBER")
    var distanzaTerraLuna : String = loc("NOTAVAIABLENUMBER")
    
    var declinazione : String = loc("NOTAVAIABLENUMBER")
    var rettaAscendente : String = loc("NOTAVAIABLENUMBER")
    var segnoZodiacale : String = loc("NOTAVAIABLENUMBER")
    var phaseAngle : String = loc("NOTAVAIABLENUMBER")
    
    
    var alba : String = loc("NOTAVAIABLENUMBER")
    var tramonto : String = loc("NOTAVAIABLENUMBER")
    
    var iconaFaseLunare : String = loc("NOTAVAIABLENUMBER")
    var titoloFaseLunare : String = loc("NOTAVAIABLENUMBER")
    
    var posizioneOrizzonte : String = loc("NOTAVAIABLENUMBER")
    
    var angoloOmbra : String = loc("NOTAVAIABLENUMBER")
    
}
