//
//  Models.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 26.03.23.
//

import Foundation

/*
    {"vehicleOdometer":0,"vehicleSoc":0,"vehicleRange":0,"pvPower":649.2,"chargePower":0,"gridPower":3174,"charging":"false","homePower":3823.2,"Total_in":5889.9185,"Total_out":387.3726,"Power_curr":3174,"outputpower":669,"energytotal":385.4,"energytoday":2.4,"dt":"2023-04-01 16:35:50"}

 */
struct EnergyDataModel: Codable {
    let id: Int
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

/*
    data for BarMark
 */
struct InOutBarChartModel: Identifiable {
//    var id: String { source }
    let id: Int
    var source: String
    var value: Int
}
extension InOutBarChartModel: Decodable { // Vermutlich nur bei json Mapping notwendig --> Codable
    enum CodingKeys: String, CodingKey {
        case id, source, value
    }
}

/*
    data for LineMark / PointMark
 */
struct LineMarkDataModel: Identifiable {
//    var id = UUID()
    var id: Date { date }
    var source: String
    var date: Date
    var value: Double
 
    init(source: String, value: Double) {
        self.source = source
        self.date = Date.now // Vorbelegung mit aktuellem Date/Time
        self.value = value
    }
}

/*
    (historical) data from PV inverter (json format)
    sample code: https://matteomanferdini.com/mvvm-pattern-ios-swift/
    codable:  https://matteomanferdini.com/codable/
    we receive data in json format -> Model has to be "Codable" !
 */
struct InverterDataModel: Identifiable, Codable {
    var id: Int
    var DT: String
    var PV: Double
}


