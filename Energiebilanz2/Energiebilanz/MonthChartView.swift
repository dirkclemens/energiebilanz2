//
//  MonthChartView.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 26.03.23.
//

import SwiftUI
import Charts

class MonthChartModelClass: ObservableObject {
    @Published var modelData : [InverterDataModel] = []
    @Published var maxPV: Double = 0.0
    
    init() {
        reload()
    }
        
    func reload() {
        let url = URL(string: Constants.monthJsonLink)!
//        let urlSession = URLSession.shared
        let urlSession = URLSession(configuration: .ephemeral) // no caching
        let task = urlSession.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                debugPrint("Error loading \(url): \(String(describing: error))")
                return
            }
            let pvvalues = try! JSONDecoder().decode([InverterDataModel].self, from: data)
            let maxPV = pvvalues.max(by: { $0.PV < $1.PV })?.PV ?? 0.0
            
            OperationQueue.main.addOperation {
                self.modelData = pvvalues
                self.maxPV = maxPV
            }
       }
       task.resume()
   }
}

struct MonthChartView: View {
    @StateObject private var viewModel = MonthChartModelClass()
    @State var rect1: CGRect = CGRect()
    @State var width1: Double = Double()
    
    var body: some View {
        
        Chart(viewModel.modelData) { element in
            BarMark(
                x: .value("Datum", stringToDate(dt: element.DT, format: "yyyy-MM")!),
                y: .value("Wert", element.PV),
                width: MarkDimension(floatLiteral: (width1 / Double((viewModel.modelData.count * 2) - 3)))
            )
            .foregroundStyle(.orange)
            .annotation(position: .overlay) {
                Text("\(String(format: "%0.0f", element.PV)) kW")
                    .font(.system(size: 10)).bold()
                    .frame(width: 90, alignment: .bottomTrailing)
                    .rotationEffect(.degrees(270))
            }
            .cornerRadius(3)
        } // Chart
        .background(GeometryGetter(rect: $rect1, width: $width1))
        .chartYAxisLabel("kW")
        .chartYScale(domain: 0 ... (viewModel.maxPV * 1.2))
//        .chartXScale(domain: 1...12)
        .chartXAxis { // wichtig: Anzeige des Monats !!!
//            AxisMarks (values: .automatic(desiredCount: 9)) { value in
            AxisMarks (preset: .aligned, values: .stride (by: .month, count: 2)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(), centered: false)
            }
        }
        .onTapGesture {
            self.viewModel.reload()
//            debug(".onTapGesture")
        }
        .frame(height: 100)

    } // View
}

struct MonthChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthChartView()
    }
}
