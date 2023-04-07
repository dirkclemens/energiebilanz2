//
//  TodayChartView.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 26.03.23.
//  MVVM --> https://matteomanferdini.com/mvvm-pattern-ios-swift/

import SwiftUI
import Charts

class TodayChartModelClass: ObservableObject {
    @Published var modelData : [InverterDataModel] = []//.allPvValues
    
    init() {
        reload()
    }

    func reload() {
        let url = URL(string: "http://xxx.xxx.de/energy.php?range=today")!
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                debugPrint("Error loading \(url): \(String(describing: error))")
                return
            }
            let modelData = try! JSONDecoder().decode([InverterDataModel].self, from: data)
            
            OperationQueue.main.addOperation {
                self.modelData = modelData
            }
       }
       task.resume()
    }
}

struct TodayChartView: View {
    @StateObject var thisChartModel = TodayChartModelClass()

    #if os(macOS)
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    #else
    let timer = Timer.publish(every: 300, on: .main, in: .common).autoconnect()
    #endif
    
    var body: some View {
        Chart(thisChartModel.modelData) { element in
            AreaMark(
                x: .value("Datum", stringToDate(dt: element.DT, format: "yyyy-MM-dd HH:mm:ss")!),
                y: .value("Wert", element.PV),
                stacking: .unstacked
            )
            .accessibilityLabel(".")
            .accessibilityValue("\(element.PV) W")
            .foregroundStyle(.orange)
        } // Chart
        .chartYAxisLabel("W")
        .onReceive(timer) { _ in
            self.thisChartModel.reload()
        }
        .onTapGesture {
            self.thisChartModel.reload()
        }
        .frame(height: 100)
    } // View
}

struct TodayChartView_Previews: PreviewProvider {
    static var previews: some View {
        TodayChartView()
    }
}
