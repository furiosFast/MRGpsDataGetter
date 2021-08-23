//
//  GpsInfoModel.swift
//  MRGpsDataGetter
//
//  Created by Marco Ricca on 20/11/2019
//
//  Created for MRGpsDataGetter in 20/11/2019
//  Using Swift 5.0
//  Running on macOS 10.14
//
//  Copyright © 2019 Fast-Devs Project. All rights reserved.
//

import UIKit

public class GpsInfoModel: NSObject {
    
    public final var locationName : String = loc("NOTAVAILABLENUMBER")

    public final var latitude : String = loc("NOTAVAILABLENUMBER")
    public final var longitude : String = loc("NOTAVAILABLENUMBER")
    public final var altitude : String = loc("NOTAVAILABLENUMBER")
    public final var speed : String = loc("NOTAVAILABLENUMBER")
    public final var verticalAccuracy : String = loc("NOTAVAILABLENUMBER")
    public final var horizontalAccuracy : String = loc("NOTAVAILABLENUMBER")
    public final var course : String = loc("NOTAVAILABLENUMBER")
    public final var floor : String = loc("NOTAVAILABLENUMBER")

}
