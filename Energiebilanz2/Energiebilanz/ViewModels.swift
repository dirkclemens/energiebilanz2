//
//  ViewModels.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 04.04.23.
//

import Foundation
import SwiftUI
import Combine

/**
 @Published wird normalerweise für die Verwaltung des Zustands von Modellobjekten, bspw. in ViewModels, verwendet. Es wird verwendet, um Änderungen an Objekten zu beobachten und diese Änderungen an alle Abonnenten des Objekts weiterzugeben.
 */

class ContentViewModel: ObservableObject {
    @Published var energyItems: [EnergyDataModel] = []
    @Published var ioDataItems: [InOutDataArrayModel] = []
    
    init() {
        fetchItems()
    }
    
    func fetchItems() {
        guard let url = URL(string: Constants.energyJsonLink) else {
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return
            }
//            debug("JSON: \(String(data: data, encoding: .utf8)!)")
            
            do {
                let decoder = JSONDecoder()
                let items = try decoder.decode([EnergyDataModel].self, from: data)
                                
                DispatchQueue.main.async {
//                    debug("JSON item count: \(items.count)")
                    self.energyItems = items
                    
                    // Create the 5 different InOutDataModel elements for the Charts
                    // and create an array of InOutDataModel of these 5 elements
                    let inOutDataModels = [
                        InOutDataModel(source: Constants.sourceErzeugung, date: Date.now, value: items.first!.pvPower * (-1)),
                       InOutDataModel(source: Constants.sourceNetzbezug, date: Date.now, value: items.first!.gridInPower * (-1)),
                       InOutDataModel(source: Constants.sourceEinspeisung, date: Date.now, value: items.first!.gridOutPower * (-1)),
                       InOutDataModel(source: Constants.sourceVerbrauch, date: Date.now, value: items.first!.homePower),
                       InOutDataModel(source: Constants.sourceLadepunkt, date: Date.now, value: items.first!.chargePower)
                    ]

                    // Create an InOutDataArrayModel with the array of InOutDataModel
                    let inOutDataArrayModel = InOutDataArrayModel(inOutItems: inOutDataModels)
                    
                    // Append this new InOutDataArrayModel to the ioDataItems array and publish it
//                    debug("inOutDataArrayModel append \(inOutDataArrayModel.inOutItems.count)")
                    if (self.ioDataItems.count > Constants.dataPoints) {
                        self.ioDataItems.remove(at: 0) // remove oldest element
                    }
                    self.ioDataItems.append(inOutDataArrayModel)
//                    debug("ioDataItems cound \(self.ioDataItems.count)")

                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}
