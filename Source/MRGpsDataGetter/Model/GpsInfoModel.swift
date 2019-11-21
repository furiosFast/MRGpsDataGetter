//
//  GpsInfoModel.swift
//  iWindRose²
//
//  Created by Marco on 26/03/18.
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
//

import UIKit

public final class GpsInfoModel: NSObject {
    
    public final var locationName : String = loc("NOTAVAIABLENUMBER")

    public final var latitude : String = loc("NOTAVAIABLENUMBER")
    public final var longitude : String = loc("NOTAVAIABLENUMBER")
    public final var altittude : String = loc("NOTAVAIABLENUMBER")
    public final var speed : String = loc("NOTAVAIABLENUMBER")
    public final var verticalAccuracy : String = loc("NOTAVAIABLENUMBER")
    public final var horizontalAccuracy : String = loc("NOTAVAIABLENUMBER")
    public final var course : String = loc("NOTAVAIABLENUMBER")

}
