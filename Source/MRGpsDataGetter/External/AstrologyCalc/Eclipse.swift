//
//  Eclipse.swift
//  AstrologyCalc
//
//  Created by  Yuri on 02/04/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import Foundation


/// Provides detailed info about eclipse (lunar or solar).
public class Eclipse {
    
    public enum EclipseType {
        case undefined
        case SolarNoncenral
        case SolarPartial
        case SolarCentralTotal
        case SolarCentralAnnular
        case SolarCentralAnnularTotal
        case LunarUmbralTotal
        case LunarUmbralPartial
        case LunarPenumbral
    }
    
    // Local visibility circumstances (lunar & solar both)
    public static let VISIBILITY_NONE             = 0;
    public static let VISIBILITY_PARTIAL          = 1;
    public static let VISIBILITY_FULL             = 2;
    public static let VISIBILITY_START_PENUMBRA   = 3;
    public static let VISIBILITY_START_PARTIAL    = 4;
    public static let VISIBILITY_START_FULL       = 5;
    public static let VISIBILITY_END_FULL         = 6;
    public static let VISIBILITY_END_PARTIAL      = 7;
    public static let VISIBILITY_END_PENUMBRA     = 8;
    
    /** UTC date & time of maximal phase of eclipse (for Earth center) */
    public var maxPhaseDate : String = loc("NOTAVAILABLENUMBER")
    
    /** Maximal phase of eclipse */
    public var phase : String = loc("NOTAVAILABLENUMBER")
    
    /** Type of eclipse */
    public var type: EclipseType = .undefined
    
    /** Minimal distance between:
     a) solar eclipse: center of Moon shadow axis and Earth center;
     b) lunar eclipse: Moon center and Earth shadow axis. */
    public var gamma : String = loc("NOTAVAILABLENUMBER")
    
    /** Radius of ...  */
    public var u : String = loc("NOTAVAILABLENUMBER")
    
    /** Eclipse visibiliy for local point */
    public var visibility : String = loc("NOTAVAILABLENUMBER")
    
    /** Julian date for observable phase */
    public var jdBestVisible : String = loc("NOTAVAILABLENUMBER")
    
    
    // LUNAR ECLIPSE
    
    /** Penumra radius (in Earth equatorial radii) */
    public var rho : String = loc("NOTAVAILABLENUMBER")
    
    /** Umbra radius (in Earth equatorial radii) */
    public var sigma : String = loc("NOTAVAILABLENUMBER")
    
    /** Semiduration of partial phase in penumbra, in minutes */
    public var sdPenumbra : String = loc("NOTAVAILABLENUMBER")
    
    /** Semiduration of partial phase, in minutes */
    public var sdPartial : String = loc("NOTAVAILABLENUMBER")
    
    /** Semiduration of total phase, in minutes */
    public var sdTotal : String = loc("NOTAVAILABLENUMBER")
    
    
    // SOLAR ECLIPSE
    
    /** Maximal local phase of eclipse */
    public var phaseLocal : String = loc("NOTAVAILABLENUMBER")
    
    /** UTC date & time eclipse maximum for local point */
    public var jdLocal : String = loc("NOTAVAILABLENUMBER")
    
    /** Time of partial phase beginning for local point */
    public var jdLocalPartialStart : String = loc("NOTAVAILABLENUMBER")
    
    /** Time of partial phase ending for local point */
    public var jdLocalPartialEnd : String = loc("NOTAVAILABLENUMBER")
}
