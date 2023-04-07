//
//  ViewModels.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 04.04.23.
//

import Foundation
import SwiftUI

/**
 @Published wird normalerweise für die Verwaltung des Zustands von Modellobjekten, bspw. in ViewModels, verwendet. Es wird verwendet, um Änderungen an Objekten zu beobachten und diese Änderungen an alle Abonnenten des Objekts weiterzugeben.
 */

class InOutBarMarkViewModel: ObservableObject {
    @Published var barMarkItems: [InOutBarChartModel] = [
        InOutBarChartModel(id: 0, source: "Erzeugung", value: 0),
        InOutBarChartModel(id: 1, source: "Netzbezug", value: 0),
        InOutBarChartModel(id: 2, source: "Einspeisung", value: 0),
        InOutBarChartModel(id: 3, source: "Verbrauch", value: 0)
    ]
    
    init() {
        update(barMarkItems)
    }
    
    func update(_ item: [InOutBarChartModel]) {
//        debug("update() -> \(self.barMarkItems.count)")
        barMarkItems.removeAll()
        barMarkItems = item
//        debug("update() -> barMarkItems.enumerated(): \(self.barMarkItems.enumerated())")
    }
}

class LineMarkViewModel: ObservableObject {
    @Published var lineMarkItems: [LineMarkDataModel] = [
        LineMarkDataModel(source: "Erzeugung", value: 0.0),
        LineMarkDataModel(source: "Netzbezug", value: 0.0),
        LineMarkDataModel(source: "Einspeisung", value: 0.0),
        LineMarkDataModel(source: "Verbrauch", value: 0.0)
    ]
    func append(_ item: [LineMarkDataModel]) {
//        debug("update() -> \(self.lineMarkItems.count)")
        if (lineMarkItems.count > Constants.dataPoints) {
            lineMarkItems.removeFirst()
        }
        lineMarkItems.append(contentsOf: item)
//        debug("update() -> lineMarkItems.enumerated(): \(self.lineMarkItems.enumerated())")
    }
}

class ContentViewModel: ObservableObject {
    @Published var energyItems: [EnergyDataModel] = []

    @StateObject var lineMarkViewModel = LineMarkViewModel()
    @StateObject var barMarkViewModel = InOutBarMarkViewModel()
    
    init() {
        _ = fetchItems()
    }
    
    func fetchItems() -> Int {
        var result = 0
        guard let url = URL(string: "http://xxx.xxx.de/energy.json") else {
            return result
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return
            }
//            debug("JSON: \(String(data: data, encoding: .utf8)!)")
            
            do {
                let decoder = JSONDecoder()
                let items = try decoder.decode([EnergyDataModel].self, from: data)
                result = items.count
                                
                DispatchQueue.main.async {
//                    debug("JSON item count: \(items.count)")
                    self.energyItems = items
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
        return result
    }
}
