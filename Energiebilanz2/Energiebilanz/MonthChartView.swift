//
//  MonthChartView.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 26.03.23.
//

import SwiftUI
import Charts

class MonthChartModelClass: ObservableObject {
    @Published var pvvalues : [InverterDataModel] = []//.allPvValues
    @Published var maxPV: Double = 0.0
    
    init() {
        reload()
    }
        
    func reload() {
//        debug("MonthChartModel()->reloadData()")
        let url = URL(string: "http://xxx.xxx.de/monthly.json")!
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                debugPrint("Error loading \(url): \(String(describing: error))")
                return
            }
            let pvvalues = try! JSONDecoder().decode([InverterDataModel].self, from: data)
            let maxPV = pvvalues.max(by: { $0.PV < $1.PV })?.PV ?? 0.0
            
            OperationQueue.main.addOperation {
                self.pvvalues = pvvalues
                self.maxPV = maxPV
            }
       }
       task.resume()
   }
}

struct MonthChartView: View {
    @StateObject var thisChartModel = MonthChartModelClass()
    @State var rect1: CGRect = CGRect()
    @State var width1: Double = Double()
    
    var body: some View {
        
        Chart(thisChartModel.pvvalues) { element in
            BarMark(
                x: .value("Datum", stringToDate(dt: element.DT, format: "yyyy-MM")!),
                y: .value("Wert", element.PV),
                width: MarkDimension(floatLiteral: (width1 / Double((thisChartModel.pvvalues.count * 2) - 3)))
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
        .chartYScale(domain: 0 ... (thisChartModel.maxPV * 1.2))
        .onTapGesture {
            self.thisChartModel.reload()
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
