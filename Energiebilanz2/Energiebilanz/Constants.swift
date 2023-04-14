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
    
    static let evccLink = "http://arend.uberspace.de:47827"
    static let energyJsonLink = "https://api.adcore.de/energy.json"
    static let todayJsonLink = "https://api.adcore.de/energy.php?range=today"
    static let weekJsonLink = "https://api.adcore.de/weekly.json"
    static let monthJsonLink = "https://api.adcore.de/monthly.json"
    static let yearJsonLink = "https://api.adcore.de/yearly.json"
        
    static let sourceErzeugung = "Erz."
    static let sourceNetzbezug = "Netzbez."
    static let sourceEinspeisung = "Einsp."
    static let sourceVerbrauch = "Verbr."
    static let sourceLadepunkt = "Ladep."

//    static let sourceErzeugung = "Erzeugung"
//    static let sourceNetzbezug = "Netzbezug"
//    static let sourceEinspeisung = "Einspeisung"
//    static let sourceVerbrauch = "Verbrauch"
//    static let sourceLadepunkt = "Ladepunkt"

    /*
    "Erzeugung": .orange,
    "Netzbezug" : Constants.steelBlue,
    "Einspeisung": Constants.lemonYellow,
    "Verbrauch" : Constants.evccGreen,
    "Ladepunkt" : Constants.aubergine]
    */
    
    /*
        to colourize the charts / barmarks, linemarks, pointmarks
     */
    static let steelBlue = Color(red: 0.20, green: 0.47, blue: 0.97)
    static let lemonYellow = Color(hue: 0.1639, saturation: 1, brightness: 1)
    static let steelGray = Color(white: 0.4745)
    static let evccGreen = Color(red:0.152, green:0.8, blue:0.255)
    static let evccOrange = Color(red:0.998, green:0.584, blue:0)
    static let aubergine = Color(red: 0.71, green: 0.42, blue: 0.87, opacity: 1.00)
    
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
