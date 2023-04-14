//
//  Models.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 26.03.23.
//  try https://app.quicktype.io

import Foundation

// Model
struct EnergyDataModel: Codable {
    var id: Int
    var vehicleOdometer: Double
    var vehicleSoc: Double
    var vehicleRange: Double
    var pvPower: Double
    var chargePower: Double
    var gridInPower: Double
    var gridOutPower: Double
    var charging: String
    var homePower: Double
    var Total_in: Double
    var Total_out: Double
    var Power_curr: Double
    var outputpower: Double
    var energytotal: Double
    var energytoday: Double
    var dt: String
}

// Model
struct InOutDataModel {
//    var id = UUID()
    var id: Date { date }
    var source: String
    var date: Date
    var value: Double
}

// Model
struct InOutDataArrayModel: Identifiable {
    var id = UUID()
    var inOutItems: [InOutDataModel]
}


/*
    (historical) data from PV inverter (json format)
    sample code: https://matteomanferdini.com/mvvm-pattern-ios-swift/
    codable:  https://matteomanferdini.com/codable/
    we receive data in json format -> Model has to be "Codable" !
 */
// Model
struct InverterDataModel: Identifiable, Codable {
//    var id = UUID()
    var id: Int // skip this
    var DT: String
    var PV: Double
}



