//
//  SoleModel.swift
//  iWindRose²
//
//  Created by Marco on 17/04/18.
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
//

import UIKit

public final class GpsSunInfoModel: NSObject {
    
    public final var mezzogiornoSolare : String = loc("NOTAVAIABLENUMBER")
    public final var mezzanotteSolare : String = loc("NOTAVAIABLENUMBER")
    
    public final var altitudine : String = loc("NOTAVAIABLENUMBER")
    public final var azimuth : String = loc("NOTAVAIABLENUMBER")

    public final var crepuscoloAstronauticoAlba : String = loc("NOTAVAIABLENUMBER")
    public final var crepuscoloNauticoAlba : String = loc("NOTAVAIABLENUMBER")
    public final var crepuscoloCivileAlba : String = loc("NOTAVAIABLENUMBER")
    public final var albaInizio : String = loc("NOTAVAIABLENUMBER")
    public final var albaFine : String = loc("NOTAVAIABLENUMBER")
    public final var crepuscoloAstronauticoTramonto : String = loc("NOTAVAIABLENUMBER")
    public final var crepuscoloNauticoTramonto : String = loc("NOTAVAIABLENUMBER")
    public final var crepuscoloCivileTramonto : String = loc("NOTAVAIABLENUMBER")
    public final var tramontoInizio : String = loc("NOTAVAIABLENUMBER")
    public final var tramontoFine : String = loc("NOTAVAIABLENUMBER")
    public final var oraDoroAlbaInizio : String = loc("NOTAVAIABLENUMBER")
    public final var oraDoroAlbaFine : String = loc("NOTAVAIABLENUMBER")
    public final var oraDoroTramontoInizio : String = loc("NOTAVAIABLENUMBER")
    public final var oraDoroTramontoFine : String = loc("NOTAVAIABLENUMBER")
    public final var oraBluAlbaInizio : String = loc("NOTAVAIABLENUMBER")
    public final var oraBluAlbaFine : String = loc("NOTAVAIABLENUMBER")
    public final var oraBluTramontoInizio : String = loc("NOTAVAIABLENUMBER")
    public final var oraBluTramontoFine : String = loc("NOTAVAIABLENUMBER")

    public final var declinazione : String = loc("NOTAVAIABLENUMBER")
    public final var rettaAscendente : String = loc("NOTAVAIABLENUMBER")
    public final var segnoZodiacale : String = loc("NOTAVAIABLENUMBER")
    public final var faseSolare : String = loc("NOTAVAIABLENUMBER")

    public final var oreLuce : String = loc("NOTAVAIABLENUMBER")

}
