//
//  InOutLineView.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 04.04.23.
//

import SwiftUI
import Charts

struct InOutLineView: View {
    /// @Binding wird normalerweise für die Übertragung von Daten zwischen verschiedenen Views innerhalb der SwiftUI-Hierarchie verwendet.
    @Binding var lineMarkItems: [LineMarkDataModel]
    /// @StateObject verwendet, um komplexe Objekte zu verfolgen, die eine Lebensdauer haben, die über die des Views hinausgeht.
    /// Es wird normalerweise für Modellobjekte verwendet, die von mehreren Views oder anderen Objekten verwendet werden können.
    @StateObject var lineMarkViewModel = LineMarkViewModel()
//    @ObservedObject var lineMarkViewModel = LineMarkViewModel()
    
    var body: some View {
        // https://github.com/jordibruin/Swift-Charts-Examples/blob/main/Swift%20Charts%20Examples/Charts/BarCharts/PyramidChart.swift
        Chart($lineMarkItems) { $item in
            
            LineMark(
                x: .value("Zeit", item.date),
                y: .value("Wert", item.value)
            )
            .lineStyle(StrokeStyle(lineWidth: 1))
            .foregroundStyle(by: .value("Quelle", item.source))
            .accessibilityLabel(".")
            .accessibilityValue("\(item.value) W")


            PointMark( // with PointMarks, the annotation will attach to the individual point
                x: .value("Zeit", item.date),
                y: .value("Wert", item.value)
            )
            .interpolationMethod(.catmullRom)
            .symbolSize(6)
            .foregroundStyle(by: .value("Quelle", item.source))
            
        } // Chart
        .chartLegend(position: .bottom, alignment: .center)
        .chartLegend(.hidden)
        .chartYAxisLabel("W")
        .chartForegroundStyleScale([
            "Erzeugung": .orange,
            "Netzbezug" : Constants.steelBlue,
            "Einspeisung": Constants.lemonYellow,
            "Verbrauch" : Constants.evccGreen]
        )
        .frame(height: 100)
    }
}

