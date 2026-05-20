//
//  WeatherAlertModel.swift
//  MRGpsDataGetter
//
//  Created by Marco Ricca on 20/05/2026
//
//  Copyright © 2026 Fast-Devs Project. All rights reserved.
//

import Foundation

public class WeatherAlertModel: NSObject, @unchecked Sendable {
    public final var summary: String = ""
    public final var severity: String = ""
    public final var source: String = ""
    public final var detailsURL: URL?
    public final var affectedRegions: [String] = []
}
