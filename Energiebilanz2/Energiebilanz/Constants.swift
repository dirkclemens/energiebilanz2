//
//  Constants.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 25.03.23.
//

import Foundation
import SwiftUI

/*
    define constants for the whole app
    seperate them from code
 */
struct Constants {
    
    static let evccLink = "http://xxx.xxx.de"
        
    /*
        to colourize the charts / barmarks, linemarks, pointmarks
     */
    static let steelBlue = Color(red: 0.20, green: 0.47, blue: 0.97)
    static let lemonYellow = Color(hue: 0.1639, saturation: 1, brightness: 1)
    static let steelGray = Color(white: 0.4745)
    static let evccGreen = Color(red:0.152, green:0.8, blue:0.255)
    static let evccOrange = Color(red:0.998, green:0.584, blue:0)
    
    /*
        amount of data points in the array for the charts
     */
#if os(macOS)
    static let dataPoints = 149
    #else
    static let dataPoints = 49
    #endif
}


/*
    Picker name values in SegmentedPicker UI  
 */
enum ProfileSection : String, CaseIterable {
    case ps_today   = "heute"
    case ps_week    = "Woche"
    case ps_month   = "Monat"
    case ps_year    = "Jahr"
    case ps_all     = "mix"
}
