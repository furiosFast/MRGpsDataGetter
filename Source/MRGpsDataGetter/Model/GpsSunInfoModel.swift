//
//  SoleModel.swift
//  iWindRose²
//
//  Created by Marco on 17/04/18.
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
//

import UIKit

public final class GpsSunInfoModel: NSObject {
    
    var mezzogiornoSolare : String = loc("NOTAVAIABLENUMBER")
    var mezzanotteSolare : String = loc("NOTAVAIABLENUMBER")
    
    var altitudine : String = loc("NOTAVAIABLENUMBER")
    var azimuth : String = loc("NOTAVAIABLENUMBER")

    var crepuscoloAstronauticoAlba : String = loc("NOTAVAIABLENUMBER")
    var crepuscoloNauticoAlba : String = loc("NOTAVAIABLENUMBER")
    var crepuscoloCivileAlba : String = loc("NOTAVAIABLENUMBER")
    var albaInizio : String = loc("NOTAVAIABLENUMBER")
    var albaFine : String = loc("NOTAVAIABLENUMBER")
    var crepuscoloAstronauticoTramonto : String = loc("NOTAVAIABLENUMBER")
    var crepuscoloNauticoTramonto : String = loc("NOTAVAIABLENUMBER")
    var crepuscoloCivileTramonto : String = loc("NOTAVAIABLENUMBER")
    var tramontoInizio : String = loc("NOTAVAIABLENUMBER")
    var tramontoFine : String = loc("NOTAVAIABLENUMBER")
    var oraDoroAlbaInizio : String = loc("NOTAVAIABLENUMBER")
    var oraDoroAlbaFine : String = loc("NOTAVAIABLENUMBER")
    var oraDoroTramontoInizio : String = loc("NOTAVAIABLENUMBER")
    var oraDoroTramontoFine : String = loc("NOTAVAIABLENUMBER")
    var oraBluAlbaInizio : String = loc("NOTAVAIABLENUMBER")
    var oraBluAlbaFine : String = loc("NOTAVAIABLENUMBER")
    var oraBluTramontoInizio : String = loc("NOTAVAIABLENUMBER")
    var oraBluTramontoFine : String = loc("NOTAVAIABLENUMBER")

    var declinazione : String = loc("NOTAVAIABLENUMBER")
    var rettaAscendente : String = loc("NOTAVAIABLENUMBER")
    var segnoZodiacale : String = loc("NOTAVAIABLENUMBER")
    var faseSolare : String = loc("NOTAVAIABLENUMBER")

    var oreLuce : String = loc("NOTAVAIABLENUMBER")

}
