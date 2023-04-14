//
//  TodayChartView.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 26.03.23.
//  MVVM --> https://matteomanferdini.com/mvvm-pattern-ios-swift/

import SwiftUI
import Charts

class TodayChartModelClass: ObservableObject {
    @Published var modelData : [InverterDataModel] = []
    
    init() {
        reload()
    }

    func reload() {
        let url = URL(string: Constants.todayJsonLink)!
//        let urlSession = URLSession.shared
        let urlSession = URLSession(configuration: .ephemeral) // no caching
        let task = urlSession.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                debugPrint("Error loading \(url): \(String(describing: error))")
                return
            }
            debug("TodayChartModelClass->reload->JSON: \(String(data: data, encoding: .utf8)!)")

            let modelData = try! JSONDecoder().decode([InverterDataModel].self, from: data)
            
            OperationQueue.main.addOperation {
                self.modelData = modelData
            }
       }
       task.resume()
    }
}

struct TodayChartView: View {
    @StateObject private var viewModel = TodayChartModelClass()

    #if os(macOS)
    private let today_timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    #else
    private let today_timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    #endif
    
    var body: some View {
        Chart(viewModel.modelData) { element in
            AreaMark(
                x: .value("Datum", stringToDate(dt: element.DT, format: "yyyy-MM-dd HH:mm:ss")!),
                y: .value("Wert", element.PV)
            )
//            .accessibilityLabel("\(Date(), formatter: Formatter.mediumTime)")
//            .accessibilityValue("\(element.PV) W")
            .foregroundStyle(.orange)
        } // Chart
        .chartYAxisLabel("W")
        .chartXAxis { // wichtig: Anzeige der Stunden !!!
//            AxisMarks (preset: .aligned, values: .automatic(desiredCount: 12)) { value in
            AxisMarks (preset: .aligned, values: .stride (by: .hour, count: 2)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.hour(), centered: false)
            }
        }
        .onReceive(today_timer) { time in
//            debug("TodayChartView.onReceive(timer) -->  \(time)")
            self.viewModel.reload()
        }
        .onTapGesture {
//            debug("TodayChartView.onTapGesture() ")
            self.viewModel.reload()
        }
        .frame(height: 100)
    } // View
}

struct TodayChartView_Previews: PreviewProvider {
    static var previews: some View {
        TodayChartView()
    }
}
