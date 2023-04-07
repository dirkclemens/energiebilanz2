//
//  InOutChartView.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 26.03.23.
//  MVVM --> https://www.hackingwithswift.com/books/ios-swiftui/introducing-mvvm-into-your-swiftui-project
//  MVVM --> https://matteomanferdini.com/mvvm-pattern-ios-swift/

import Foundation
import SwiftUI
import Charts

class InOutChartViewModel: ObservableObject {
//    @Published var inOutModel : [InOutChartModel?] = []
//    @Published var inOutModel : [InOutChartModel?] = Array() //Array(repeating: nil, count: 10)
    @Published var inOutModel : [InOutBarChartModel?] = [
        InOutBarChartModel(id: 0, source: "Erzeugung", value: 10),
        InOutBarChartModel(id: 1, source: "Netzbezug", value: 20),
        InOutBarChartModel(id: 2, source: "Einspeisung", value: 30),
        InOutBarChartModel(id: 3, source: "Verbrauch", value: 40)
    ]
    
    init() {
        debug("InOutChartViewModel -> init()")
    }
    
    func fetchData() {
        debug("InOutChartViewModel -> fetchData()")
//        let task = urlSession.dataTask(with: url) { (data, response, error) in

//            let values = try! JSONDecoder().decode([InOutChartModel].self, from: data)
//            let values = [
//                .init(source: "Erzeugung", value: 10),
//                .init(source: "Netzbezug", value: 20),
//                .init(source: "Einspeisung", value: 30),
//                .init(source: "Verbrauch", value: 40)
//            ]
        
//            OperationQueue.main.addOperation {
//                self.inOutModel = values
//            }
//       }
//       task.resume()
   }
}

//final class InOutChartViewModel: Identifiable {
//    let source: InOutChartModel
//
//    init(source: InOutChartModel) {
//        self.source = source
//    }
//}


struct InOutChartView: View {
    @StateObject private var thisViewModel = InOutChartViewModel()

    @State var barMarkData: [InOutBarChartModel] = [
        .init(id: 0, source: "Erzeugung", value: 0),
        .init(id: 1, source: "Netzbezug", value: 0),
        .init(id: 2, source: "Einspeisung", value: 0),
        .init(id: 3, source: "Verbrauch", value: 0)
    ]
        
    var body: some View {
//        Text("InOutChartView()")
            Chart(barMarkData, id: \.source) { element in
                //        Chart(thisViewModel.inOutModel.indices) { element in
                //        Chart(thisViewModel.inOutModel.indices) { element in
                BarMark(
                    x: .value("Energiebilanz", element.value)
                )
                .foregroundStyle(by: .value("Quelle", element.source))
                .annotation(position: .overlay, alignment: .center) {
                    Text("\(element.value) W").font(.caption)
                }
                .foregroundStyle(Color.clear)
                .cornerRadius(5)
            } // Chart
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(2)
            }
            .chartLegend(position: .bottom, alignment: .center)
            .chartForegroundStyleScale([
                "Erzeugung": .orange,
                "Netzbezug" : Constants.steelBlue,
                "Einspeisung": Constants.lemonYellow,
                "Verbrauch" : Constants.evccGreen]
            )
            .frame(minHeight: 60, maxHeight: 60)
            .frame(idealWidth: 350)
//        List {}.onAppear(perform: thisViewModel.fetchData)
    }
}

struct InOutChartView_Previews: PreviewProvider {
    static var previews: some View {
        Text("no Preview")
//        InOutChartView()
    }
}

extension InOutChartView {
    @MainActor class InOutChartViewModel: ObservableObject {
    }
}
