//
//  InOutLineView.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 04.04.23.
//

import SwiftUI
import Charts

struct InOutLineView: View {

    // https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app#Share-an-object-throughout-your-app
    @EnvironmentObject var viewModel: ContentViewModel
    
    var body: some View {

        Chart {
            ForEach(viewModel.ioDataItems) { inOutItem in
//                Text("ForEach(Array ... \(inOutItem.inOutItems.count)")
                ForEach(inOutItem.inOutItems, id: \.id) { item in
//                    Text("---> \(lmitem.date) / \(lmitem.value)")
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
        
                }
            }
        } // Chart
        .chartLegend(position: .bottom, alignment: .center)
        .chartLegend(.hidden)
        .chartYAxisLabel("W")
        .chartForegroundStyleScale([
            Constants.sourceErzeugung: .orange,
            Constants.sourceNetzbezug: Constants.steelBlue,
            Constants.sourceEinspeisung: Constants.lemonYellow,
            Constants.sourceVerbrauch: Constants.evccGreen,
            Constants.sourceLadepunkt: Constants.aubergine]
        )
        .frame(height: 100)
        .onTapGesture {
            // debug(".onTapGesture()")
            viewModel.fetchItems()
        }
    }
}

