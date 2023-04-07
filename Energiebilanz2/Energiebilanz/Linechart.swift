//
//  Linechart.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 25.03.23.
//

import SwiftUI
import Charts

/*
    https://www.hackingwithswift.com/forums/swiftui/charts-multiple-lines-data-separation/20102
 */
struct Linechart: View {

    var lineMarkData: MqttData
//    @State var lineMarkData: [MqttData] = [
//        .init(source: "Erzeugung", value: 0.0),
//        .init(source: "Netzbezug", value: 0.0),
//        .init(source: "Einspeisung", value: 0.0),
//        .init(source: "Verbrauch", value: 0.0)
//    ]
    
    var body: some View {
        Chart(lineMarkData, id: \.source) { element in

            LineMark(
                x: .value("Zeit", element.date),
                y: .value("Wert", element.value)
            )
            .lineStyle(StrokeStyle(lineWidth: 1))
            .foregroundStyle(by: .value("Quelle", element.source))
            .accessibilityLabel(".")
            .accessibilityValue("\(element.value) W")
//                .symbol {
//                    Circle().fill(by: .yellow).frame(width: 4)
//                }
            


            PointMark( // with PointMarks, the annotation will attach to the individual point
                x: .value("Zeit", element.date),
                y: .value("Wert", element.value)
            )
            .interpolationMethod(.catmullRom)
//                .symbolSize(0) // hide the existing symbol
            .symbolSize(6)
//                .symbol(by: .value("Quelle", element.source))
            .foregroundStyle(by: .value("Quelle", element.source))
//                .position(by: .value("Quelle", element.source))
            
//                .annotation(position: .top, alignment: .trailing, spacing: 26) {
//                    Text(String(format: "%.1f W", element.value))
//                        .font(.caption)
//                }
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
    } // View
    
}

struct Linechart_Previews: PreviewProvider {
    static var previews: some View {
        Linechart(lineMarkData: $lineMarkData)
    }
}
