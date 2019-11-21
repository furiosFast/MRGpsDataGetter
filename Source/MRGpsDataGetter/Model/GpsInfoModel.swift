//
//  GpsInfoModel.swift
//  iWindRose²
//
//  Created by Marco on 26/03/18.
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
//

import UIKit

public final class GpsInfoModel: NSObject {
    
    public final var localita : String = loc("NOTAVAIABLENUMBER")

    public final var latitudine : String = loc("NOTAVAIABLENUMBER")
    public final var longitudine : String = loc("NOTAVAIABLENUMBER")
    public final var altitudine : String = loc("NOTAVAIABLENUMBER")
    public final var velocita : String = loc("NOTAVAIABLENUMBER")
    public final var precisione : String = loc("NOTAVAIABLENUMBER")

}
