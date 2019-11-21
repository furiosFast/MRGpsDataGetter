//
//  GpsPlotInfoModel.swift
//  MRGpsDataGetter
//
//  Created by Marco Ricca on 21/11/2019
//
//  Created for MRGpsDataGetter in 21/11/2019
//  Using Swift 5.0
//  Running on macOS 10.14
//
//  Copyright © 2019 Fast-Devs Project. All rights reserved.
//
		

import UIKit

public final class GpsPlotInfoModel: NSObject, NSCoding {
    
    public final var plotDataWindName: [String] = []
    public final var plotData: [Double] = []
    public final var plotDataTime: [String] = []

    
    init(_ plotDataWindName: [String], _ plotData: [Double], _ plotDataTime: [String]) {
        self.plotDataWindName = plotDataWindName
        self.plotData = plotData
        self.plotDataTime = plotDataTime
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.plotDataWindName = aDecoder.decodeObject(forKey: "plotDataWindName") as! [String]
        self.plotData = aDecoder.decodeObject(forKey: "plotData") as! [Double]
        self.plotDataTime = aDecoder.decodeObject(forKey: "plotDataTime") as! [String]
    }
    
    public func encode(with encoder: NSCoder) {
        encoder.encode(self.plotDataWindName, forKey: "plotDataWindName")
        encoder.encode(self.plotData, forKey: "plotData")
        encoder.encode(self.plotDataTime, forKey: "plotDataTime")
    }

}
