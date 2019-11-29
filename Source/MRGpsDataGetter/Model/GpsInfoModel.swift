//
//  GpsInfoModel.swift
//  iWindRose²
//
//  Created by Marco on 26/03/18.
//  Copyright © 2018 Fast-Devs Project. All rights reserved.
//

import UIKit

public final class GpsInfoModel: NSObject {
    
    public final var locationName : String = loc("NOTAVAILABLENUMBER")

    public final var latitude : String = loc("NOTAVAILABLENUMBER")
    public final var longitude : String = loc("NOTAVAILABLENUMBER")
    public final var altitude : String = loc("NOTAVAILABLENUMBER")
    public final var speed : String = loc("NOTAVAILABLENUMBER")
    public final var verticalAccuracy : String = loc("NOTAVAILABLENUMBER")
    public final var horizontalAccuracy : String = loc("NOTAVAILABLENUMBER")
    public final var course : String = loc("NOTAVAILABLENUMBER")

}
