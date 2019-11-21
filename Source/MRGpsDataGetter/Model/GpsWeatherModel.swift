//
//  MeteoModel.swift
//  iWindRose²
//
//  Created by Marco on 25/03/18.
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
//

import UIKit
import CoreLocation

public final class GpsWeatherModel: NSObject {
    
    public final var velocitaVento : String = loc("NOTAVAIABLENUMBER")
    public final var forzaScalaBeaufortVento : String = loc("NOTAVAIABLENUMBER")
    public final var angoloVento : String = loc("NOTAVAIABLENUMBER")
    public final var nomeVento : String = loc("NOTAVAIABLENUMBER")
    public final var nomeIconaVento : String = loc("NOTAVAIABLENUMBER")
    public final var coloreBollinoVento : String = loc("NOTAVAIABLENUMBER")

    public final var descrizioneTempo : String = loc("NOTAVAIABLENUMBER")
    public final var nomeIconaMeteo : String = loc("NOTAVAIABLENUMBER")
    
    public final var precipitazioni1h : String = loc("NOTAVAIABLENUMBER")
    public final var precipitazioni3h : String = loc("NOTAVAIABLENUMBER")
    public final var neve1h : String = loc("NOTAVAIABLENUMBER")
    public final var neve3h : String = loc("NOTAVAIABLENUMBER")
    public final var visibilita : String = loc("NOTAVAIABLENUMBER")
    public final var umidita : String = loc("NOTAVAIABLENUMBER")
    public final var pressione : String = loc("NOTAVAIABLENUMBER")
    public final var pressioneMare : String = loc("NOTAVAIABLENUMBER")
    public final var pressioneSuolo : String = loc("NOTAVAIABLENUMBER")
    
    public final var nuvole : String = loc("NOTAVAIABLENUMBER")

    public final var altaMarea : String = loc("NOTAVAIABLENUMBER")
    public final var bassaMarea : String = loc("NOTAVAIABLENUMBER")

    public final var temperatura : String = loc("NOTAVAIABLENUMBER")
    public final var temperaturaMin : String = loc("NOTAVAIABLENUMBER")
    public final var temperaturaMax : String = loc("NOTAVAIABLENUMBER")
    
    public final var data : String = loc("NOTAVAIABLENUMBER")
    public final var ora : String = loc("NOTAVAIABLENUMBER")
    public final var dataOra : String = loc("NOTAVAIABLENUMBER")

    public final var posizioneCorrente: CLLocation? = nil
    public final var posizioneCorrenteString: String? = loc("NOTAVAIABLENUMBER")

}
