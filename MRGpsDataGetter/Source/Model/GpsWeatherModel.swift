//
//  MeteoModel.swift
//  iWindRose²
//
//  Created by Marco on 25/03/18.
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
//

import UIKit
import CoreLocation

class GpsWeatherModel: NSObject {
    
    var velocitaVento : String = loc("NOTAVAIABLENUMBER")
    var forzaScalaBeaufortVento : String = loc("NOTAVAIABLENUMBER")
    var angoloVento : String = loc("NOTAVAIABLENUMBER")
    var nomeVento : String = loc("NOTAVAIABLENUMBER")
//    var nomeIconaVento : String = loc("NOTAVAIABLENUMBER")
    var coloreBollinoVento : String = loc("NOTAVAIABLENUMBER")

    var descrizioneTempo : String = loc("NOTAVAIABLENUMBER")
    var nomeIconaMeteo : String = loc("NOTAVAIABLENUMBER")
    
    var precipitazioni1h : String = loc("NOTAVAIABLENUMBER")
    var precipitazioni3h : String = loc("NOTAVAIABLENUMBER")
    var neve1h : String = loc("NOTAVAIABLENUMBER")
    var neve3h : String = loc("NOTAVAIABLENUMBER")
    var visibilita : String = loc("NOTAVAIABLENUMBER")
    var umidita : String = loc("NOTAVAIABLENUMBER")
    var pressione : String = loc("NOTAVAIABLENUMBER")
    var pressioneMare : String = loc("NOTAVAIABLENUMBER")
    var pressioneSuolo : String = loc("NOTAVAIABLENUMBER")
    
    var nuvole : String = loc("NOTAVAIABLENUMBER")

    var altaMarea : String = loc("NOTAVAIABLENUMBER")
    var bassaMarea : String = loc("NOTAVAIABLENUMBER")

    var temperatura : String = loc("NOTAVAIABLENUMBER")
    var temperaturaMin : String = loc("NOTAVAIABLENUMBER")
    var temperaturaMax : String = loc("NOTAVAIABLENUMBER")
    
    var data : String = loc("NOTAVAIABLENUMBER")
    var ora : String = loc("NOTAVAIABLENUMBER")
    var dataOra : String = loc("NOTAVAIABLENUMBER")

    var posizioneCorrente: CLLocation? = nil
    var posizioneCorrenteString: String? = loc("NOTAVAIABLENUMBER")

}
